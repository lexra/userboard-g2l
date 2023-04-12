DEPENDENCIES = libdrm libpng
CFLAGS = -Irecipe-sysroot/usr/include/drm -Irecipe-sysroot/usr/include/SDL2 -Irecipe-sysroot/usr/include/GLES2
LDFLAGS += -ldrm -lpng16 -lz -lpthread -lSDL2 -lGLESv1_CM -lGLESv2

all: drm2png ntpc fbgrab i2c_read_data hello_triangle

i2c_read_data: i2c_read_data.o
	$(CC) $@.o -o $@ $(LDFLAGS)

fbgrab: fbgrab.o
	$(CC) $@.o -o $@ $(LDFLAGS)

ntpc: ntpc.o
	$(CC) $@.o -o $@ $(LDFLAGS)

drm2png: drm2png.o
	$(CC) $@.o -o $@ $(LDFLAGS)

hello_triangle: hello_triangle.o
	$(CXX) -O $@.o -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.cpp
	$(CXX) -O $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o drm2png ntpc fbgrab i2c_read_data
