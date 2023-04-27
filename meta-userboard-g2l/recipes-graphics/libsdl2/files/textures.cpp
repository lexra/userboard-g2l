#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <png.h>
#include <math.h>

//#include <SDL2/SDL.h>
#include <SDL.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <EGL/egl.h>

#define  ASSETS_DIR "assets/"

SDL_Window * mainwindow;
SDL_GLContext maincontext;

GLuint gvPositionHandle;   // shader handler
GLuint gvTexCoordHandle;
GLuint gvSamplerHandle;
GLuint gvMatrixHandle;
GLuint gvRotateHandle;

float mvp_matrix[] =
{
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f
};

float rotate_matrix[] =
{
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f
};

struct {
    int w;
    int h;
} screen;

struct ImageData {
    unsigned char *pixels;
    int width;
    int height;
    int nbColors;
    char *filename;
    GLuint type;
};
typedef struct ImageData ImageData;

struct TextureInfos {
    float x;
    float y;
    float angle;
    // pivot point
    float px;
    float py;
    // velocity
    float vx;
    float vy;
    float vr;
    GLuint texture;
    int width;
    int height;
    GLfloat *vertices;
    int verticesSize;
    GLuint vertexBuffer;
    GLuint indexBuffer;
    GLushort *indices;
};
typedef struct TextureInfos TextureInfos;

char *loadFile(const char *filename, int *size) {
    SDL_RWops * file;
    char * buffer;
    char filename_final[256] = "";
    int finalPos;
    int n_blocks;

    strcpy(filename_final, ASSETS_DIR );
    strcat(filename_final, filename);
    file = SDL_RWFromFile(filename_final, "rb");
    assert(0 != file);

    SDL_RWseek(file, 0, SEEK_END);
    finalPos = SDL_RWtell(file);
    SDL_RWclose(file);

    buffer = (char *)calloc( 1, sizeof(char) * (finalPos + 1));
    file = SDL_RWFromFile(filename_final, "rb");
    n_blocks = SDL_RWread(file, buffer, 1, finalPos);
    *size = finalPos;

    SDL_RWclose(file);
    return buffer;
}

unsigned char *read_png_file(const char *filename, int *w, int *h) {
	png_byte color_type;
	png_byte bit_depth;
	int stride = 0;
	int i;
	png_bytep png_buffer = 0, png_bufferp = 0;
    	char filename_final[256] = "";

	strcpy(filename_final, ASSETS_DIR );
	strcat(filename_final, filename);
	FILE *fp = fopen(filename_final, "rb");

	png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL); assert(0 != png);
	png_infop info = png_create_info_struct(png);  assert(0 != info);
	setjmp(png_jmpbuf(png));

	png_init_io(png, fp);
	png_read_info(png, info);

	*w      = png_get_image_width(png, info);
	*h     = png_get_image_height(png, info);
	color_type = png_get_color_type(png, info);
	bit_depth  = png_get_bit_depth(png, info);

	if(bit_depth == 16)							png_set_strip_16(png);
	if(color_type == PNG_COLOR_TYPE_PALETTE)				png_set_palette_to_rgb(png);
	if(color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
	png_set_expand_gray_1_2_4_to_8(png);
	if(png_get_valid(png, info, PNG_INFO_tRNS))
	png_set_tRNS_to_alpha(png);
	if(color_type == PNG_COLOR_TYPE_RGB || color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_PALETTE)
	png_set_filler(png, 0xFF, PNG_FILLER_AFTER);
	if(color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
	png_set_gray_to_rgb(png);
	png_read_update_info(png, info);

	stride = png_get_rowbytes(png, info);
	printf("(%s %d) stride=%d\n", __FILE__, __LINE__, stride);

	png_buffer = (png_bytep)malloc(stride * *h);
	png_bufferp = png_buffer;
	for (i = 0; i < *h; i++)
		png_read_row(png, png_bufferp, 0), png_bufferp += stride;
	fclose(fp);
	return (unsigned char *)png_buffer;
}

void loadPNG(struct ImageData *data)
{
	int w, h;

	data->pixels = read_png_file(data->filename, &w, &h);
	data->width = w;
	data->height = h;
	data->nbColors = 4;
	data->type = GL_RGBA;
	return;
}

int loadTexture(struct TextureInfos *infos, struct ImageData *data, float xscale, float yscale) {
    float hw;
    float hh;

    glGenTextures(1, &infos->texture);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, infos->texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, data->type, data->width, data->height, 0, data->type, GL_UNSIGNED_BYTE, data->pixels);

    infos->width = xscale * data->width;
    infos->height = yscale * data->height;

    // init values
    infos->x = 0;
    infos->y = 0;
    infos->px = 0;
    infos->py = 0;
    infos->vx = 0;
    infos->vy = 0;

    hw = infos->width / 2.0;
    hh = infos->height / 2.0;

    infos->verticesSize = 4;
    infos->vertices = (GLfloat *)malloc(20 * sizeof(GLfloat));

    // Position 0
    infos->vertices[0] = -hw;
    infos->vertices[1] = hh;
    infos->vertices[2] = 0.0f;

    // TexCoord 0
    infos->vertices[3] = 0.0f;
    infos->vertices[4] = 0.0f;

    // Position 1
    infos->vertices[5] = -hw;
    infos->vertices[6] = -hh;
    infos->vertices[7] = 0.0f;

    // TexCoord 1
    infos->vertices[8] = 0.0f;
    infos->vertices[9] = 1.0f;

    // Position 2
    infos->vertices[10] = hw;
    infos->vertices[11] = -hh;
    infos->vertices[12] = 0.0f;

    // TexCoord 2
    infos->vertices[13] = 1.0f;
    infos->vertices[14] = 1.0f;

    // Position 3
    infos->vertices[15] = hw;
    infos->vertices[16] = hh;
    infos->vertices[17] = 0.0f;

    // TexCoord 3
    infos->vertices[18] = 1.0f;
    infos->vertices[19] = 0.0f;

// VAO, VBO
    glGenBuffers(1, &infos->vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, infos->vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 20 * sizeof(GLfloat), infos->vertices, GL_STATIC_DRAW);

    infos->indices = (GLushort *)malloc(6 * sizeof(GLshort));
    infos->indices[0] = 0;
    infos->indices[1] = 1;
    infos->indices[2] = 2;
    infos->indices[3] = 0;
    infos->indices[4] = 2;
    infos->indices[5] = 3;

// EBO
    glGenBuffers(1, &infos->indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, infos->indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(GLushort), infos->indices, GL_STATIC_DRAW);

    return 0;
}

void transformTexture(TextureInfos * texture, float tx, float ty, float angle) {
	float cos_a, sin_a;
	int i, j;
	float x, y, new_x, new_y;
	int size = texture->verticesSize * 5;

	texture->x += tx;
	texture->y += ty;

	cos_a = cos(angle);
	sin_a = sin(angle);

	for(i = 0; i < size; i+=5) {
		// back to the origin
		x = texture->vertices[i+0] - texture->x;
		y = texture->vertices[i+1] - texture->y;

		// rotate point
		new_x = x * cos_a - y * sin_a;
		new_y = x * sin_a + y * cos_a;

		// translate back from pivot and add translation
		new_x = new_x + texture->x + tx;
		new_y = new_y + texture->y + ty;

		texture->vertices[i + 0] = new_x;
		texture->vertices[i + 1] = new_y;
	}
	return;
}

int drawTexture(TextureInfos * texture, float x, float y, float angle) {
    GLsizei stride = 5 * sizeof(GLfloat); // 3 for position, 2 for texture

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, texture->vertices);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, stride, texture->vertices + 3);

    // Bind the texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture->texture);

    // matrix transformations
    mvp_matrix[12] = 2.0 * x / (float)screen.w;
    mvp_matrix[13] = 2.0 * y / (float)screen.h;

    rotate_matrix[0] = cos(angle);
    rotate_matrix[1] = sin(angle);
    rotate_matrix[4] = -rotate_matrix[1];
    rotate_matrix[5] = rotate_matrix[0];

    glUniformMatrix4fv(gvRotateHandle, 1, GL_FALSE, rotate_matrix);
    glUniformMatrix4fv(gvMatrixHandle, 1, GL_FALSE, mvp_matrix);

    glDrawElements(GL_TRIANGLES, ((texture->verticesSize - 2) * 3), GL_UNSIGNED_SHORT, texture->indices);
    return 0;
}

GLuint loadShader(GLenum type, const char * filename) {
    GLuint shader;
    GLint compiled;
    int size;

    shader = glCreateShader(type), assert(0 != shader);
    const GLchar *buffer = (const GLchar*) loadFile(filename, &size);
    glShaderSource(shader, 1, &buffer, NULL);

    // Compile the shader
    glCompileShader(shader);
    //free(buffer);

    // Check the compile status
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    assert(compiled);
    return shader;
}

GLuint initProgram(const char * vertexFile, const char * fragmentFile) {
    // create the shaders and the program
    GLuint vertexShader;
    GLuint fragmentShader;
    GLint linked;

    vertexShader = loadShader(GL_VERTEX_SHADER, vertexFile);
    fragmentShader = loadShader(GL_FRAGMENT_SHADER, fragmentFile);
    GLuint programObject = glCreateProgram();

    glAttachShader(programObject, vertexShader);
    glAttachShader(programObject, fragmentShader);

    // Link the program
    glLinkProgram(programObject);

    // Check the link status
    glGetProgramiv(programObject, GL_LINK_STATUS, &linked);

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return programObject;
}

int useProgram(GLuint programObject) {
    glUseProgram(programObject);

    gvPositionHandle = glGetAttribLocation(programObject, "a_position");
    gvTexCoordHandle = glGetAttribLocation(programObject, "a_texCoord");
    gvSamplerHandle = glGetUniformLocation(programObject, "s_texture");

    gvMatrixHandle = glGetUniformLocation(programObject, "mvp_matrix");
    gvRotateHandle = glGetUniformLocation(programObject, "rotate_matrix");

    glEnableVertexAttribArray(gvPositionHandle);
    glEnableVertexAttribArray(gvTexCoordHandle);
	return 0;
}

int main(int argc, char **argv) {
	int w, h;
	int done = 0;
	int res;
	SDL_DisplayMode mode;
	SDL_Event event;
	GLuint textureProgram;
	struct ImageData png;
	struct TextureInfos texture;
    	float zoom = 1.0f;

	res = SDL_Init(SDL_INIT_EVERYTHING), assert(0 == res);
	res = SDL_GetDesktopDisplayMode(0, &mode), assert(0 == res);
	w = screen.w = mode.w; h = screen.h = mode.h;

	zoom = 1.0f;
	mvp_matrix[0] = (zoom * 2.0) / (float)screen.w;
	mvp_matrix[5] = (zoom * 2.0) / (float)screen.h;
    	mainwindow = SDL_CreateWindow("Simple texture moving", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, w, h, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN), assert(0 != mainwindow);
	//res = SDL_SetWindowFullscreen(mainwindow, SDL_TRUE), assert(0 == res);
	maincontext = SDL_GL_CreateContext(mainwindow), assert(0 != maincontext);
	glViewport(0, 0, w, h);
	glClear(GL_COLOR_BUFFER_BIT);
	SDL_GL_SwapWindow(mainwindow);
	glClear(GL_COLOR_BUFFER_BIT);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	textureProgram = initProgram("vertex-shader-1.vert", "texture-shader-1.frag");

	png.filename = "awesomeface.png";
	loadPNG(&png);
        loadTexture(&texture, &png, 1.0, 1.0);
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        transformTexture(&texture, 0, screen.h / 4.0, 0.00);

	while (!done) {
        	while (SDL_PollEvent(&event)) {
			if(event.type == SDL_WINDOWEVENT_CLOSE || event.type == SDL_QUIT)
				done = 1;
		}
		glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
		useProgram(textureProgram);
		transformTexture(&texture, 0, 0, 0.01);
		drawTexture(&texture, 0, 0, 0);

		SDL_GL_SwapWindow(mainwindow);
	}
	return 0;
}
