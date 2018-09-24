# FROM defines the base image
FROM tensorflow/tensorflow:latest-gpu
#FROM tensorflow/tensorflow:nightly-devel

RUN apt-get update && apt-get install -y --no-install-recommends \
	apt-utils \
        build-essential \
	wget \
        curl \
        pkg-config \
        rsync \
	nano \
	git \
	protobuf-compiler \
	python-pil \
	python-lxml \
	python-tk \
        software-properties-common \
        unzip \
        && \
	apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/tensorflow/models.git && \
    mv models /usr/local/lib/python2.7/dist-packages/tensorflow/models

# Install object detection api dependencies
RUN apt-get install -y protobuf-compiler python-pil python-lxml python-tk && \
    pip install Cython && \
    pip install contextlib2 && \
    pip install jupyter && \
    pip install matplotlib && \
    pip install natsort

# Install pycocoapi
RUN git clone --depth 1 https://github.com/cocodataset/cocoapi.git && \
    cd cocoapi/PythonAPI && \
    make -j8 && \
    cp -r pycocotools /usr/local/lib/python2.7/dist-packages/tensorflow/models/research && \
    cd ../../ && \
    rm -rf cocoapi

# Get protoc 3.0.0, rather than the old version already in the container
RUN curl -OL "https://github.com/google/protobuf/releases/download/v3.0.0/protoc-3.0.0-linux-x86_64.zip" && \
    unzip protoc-3.0.0-linux-x86_64.zip -d proto3 && \
    mv proto3/bin/* /usr/local/bin && \
    mv proto3/include/* /usr/local/include && \
    rm -rf proto3 protoc-3.0.0-linux-x86_64.zip

# Run protoc on the object detection repo
RUN cd /usr/local/lib/python2.7/dist-packages/tensorflow/models/research && \
    protoc object_detection/protos/*.proto --python_out=.

# Set the PYTHONPATH to finish installing the API
ENV PYTHONPATH $PYTHONPATH:/usr/local/lib/python2.7/dist-packages/tensorflow/models/research:/usr/local/lib/python2.7/dist-packages/tensorflow/models/research/slim

# Grab various data files which are used throughout the demo: dataset,
# pretrained model, and pretrained TensorFlow Lite model. Install these all in
# the same directories as recommended by the blog post.

# Pets example dataset
RUN mkdir -p /tmp/pet_faces_tfrecord/ && \
    cd /tmp/pet_faces_tfrecord && \
    curl "http://download.tensorflow.org/models/object_detection/pet_faces_tfrecord.tar.gz" | tar xzf -

# Pretrained model
# This one doesn't need its own directory, since it comes in a folder.
RUN cd /tmp && \
    curl -O "http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_0.75_depth_300x300_coco14_sync_2018_07_03.tar.gz" && \
    tar xzf ssd_mobilenet_v1_0.75_depth_300x300_coco14_sync_2018_07_03.tar.gz && \
    rm ssd_mobilenet_v1_0.75_depth_300x300_coco14_sync_2018_07_03.tar.gz

# Trained TensorFlow Lite model. This should get replaced by one generated from
# export_tflite_ssd_graph.py when that command is called.
RUN cd /tmp && \
    curl -L -o tflite.zip \
    https://storage.googleapis.com/download.tensorflow.org/models/tflite/frozengraphs_ssd_mobilenet_v1_0.75_quant_pets_2018_06_29.zip && \
    unzip tflite.zip -d tflite && \
    rm tflite.zip

# set the working directory 
WORKDIR /usr/local/lib/python2.7/dist-packages/tensorflow/models/research/object_detection/
COPY . .

EXPOSE 8008
EXPOSE 8080
EXPOSE 8888

CMD bash setup_script.sh; bash run_script.sh
