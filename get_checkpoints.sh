echo "Containers running:"
sudo docker ps

echo "Reading container called yannis"
echo "note: if you change container name, change it also in get_last_checkpoint_number"
containername=yannis

echo "Getting last checkpoint number:"
nr_ckpt=$(python get_last_checkpoint_number.py 2>&1)
echo "Last checkpoint number is: $nr_ckpt"

echo "Cleaning existing exports"
sudo nvidia-docker exec -it "$containername" rm -rf exporting/*

echo "Exporting your selection"
sudo nvidia-docker exec -it "$containername" python export_inference_graph.py \
    --input_type image_tensor \
    --pipeline_config_path training/ssd_inception_v2_coco.config \
    --trained_checkpoint_prefix training/"model.ckpt-""$nr_ckpt" \
    --output_directory ./exporting

echo "Cleaning exporting/ dir in VM (not container)"
sudo rm -rf exporting/
echo "Copying files from docker container to exporting/ (VM)"
sudo docker cp "$containername":/usr/local/lib/python2.7/dist-packages/tensorflow/models/research/object_detection/exporting/ .
sudo touch 'exporting/'$nr_ckpt".txt"
