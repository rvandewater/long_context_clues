#!/bin/bash
#SBATCH --job-name=hyena-1k-v8
#SBATCH --output=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/hyena-1k-v8_%A.out
#SBATCH --error=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/hyena-1k-v8_%A.err
#SBATCH --time=48:00:00
#SBATCH --partition=gpu
#SBATCH --nodelist=secure-gpu-7
#SBATCH --mem=200G
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:4

source base.sh

python3 run.py \
    +models=hyena \
    +data=v8 \
    data.dataloader.batch_size=8 \
    trainer.accumulate_grad_batches=8 \
    trainer.optimizer.lr=6e-4 \
    data.dataloader.n_workers=10 \
    trainer.devices=[0,1,2,3] \
    model.config_kwargs.n_layer=4 \
    model.config_kwargs.d_model=256 \
    model.config_kwargs.d_inner=2048 \
    model.config_kwargs.max_seq_len=1024 \
    data.dataloader.max_length=1024 \
    main.path_to_output_dir=/share/pi/nigam/mwornow/hf_ehr/cache/runs/hyena-1k-v8/ \
    logging.wandb.name=hyena-1k-v8