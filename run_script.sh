python legacy/train.py --logtostderr \
	--train_dir=training/ \
	--pipeline_config_path=training/ssd_inception_v2_coco.config
	--num_clones=2
	--ps_tasks=1

python legacy/eval.py \
    --logtostderr \
    --pipeline_config_path=training/ssd_inception_v2_coco.config \
    --checkpoint_dir=training/ \
    --eval_dir=eval/
