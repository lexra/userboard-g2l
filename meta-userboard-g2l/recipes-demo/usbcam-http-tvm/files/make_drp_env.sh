
#
#  Original code (C) Copyright EdgeCortix, Inc. 2022
#  Modified Portion (C) Copyright Renesas Electronics Corporation 2022
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Set symbolic link
cd tvm/3rdparty
rm -rfv dmlc-core rang vta-hw protobuf libbacktrace onnx
ln -sf ../../3rdparty/dmlc-core .
ln -sf ../../3rdparty/rang .
ln -sf ../../3rdparty/vta-hw .
ln -sf ../../3rdparty/protobuf .
ln -sf ../../3rdparty/libbacktrace .
ln -sf ../../3rdparty/onnx .
cd -

# Set DRP-plugin python code
cp -r obj/python ./tvm/.

# Set libralies
cp -r ./obj/build ./tvm/.
if [ -z "${PRODUCT}" ]; then
  echo "Error: PRODUCT variable is not set"
  exit 1
fi
if [ ${PRODUCT} != "V2MA" ] && [ ${PRODUCT} != "V2M" ] && [ ${PRODUCT} != "V2L" ]; then
  echo "Error: Unsupported value ${PRODUCT} is set in PRODUCT variable"
  exit 1
fi
mkdir -p ./tvm/build_runtime
cp ./obj/build_runtime/${PRODUCT}/libtvm_runtime.so ./tvm/build_runtime/
