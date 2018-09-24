echo 'fixing annotation paths, filenames etc. ..'
echo 'creating csv file from annotation xmls ..'
python xml_to_csv.py
echo 'splitting into train, test ..'
python split_labels.py

echo 'generating TFrecord files for train and test'
python generate_tfrecord.py --csv_input=data/train_labels.csv --output_path=data/train.record
python generate_tfrecord.py --csv_input=data/test_labels.csv --output_path=data/test.record

sed -i 's@PATH_TO_BE_CONFIGURED@'"$PWD"'@' ./training/ssd_inception_v2_coco.config
