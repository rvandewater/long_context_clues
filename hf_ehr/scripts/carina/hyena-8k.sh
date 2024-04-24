#!/bin/bash
#SBATCH --job-name=hyena-8k-v8
#SBATCH --output=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/hyena-8k-v8_%A.out
#SBATCH --error=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/hyena-8k-v8_%A.err
#SBATCH --time=48:00:00
#SBATCH --partition=nigam-a100
#SBATCH --mem=300G
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:4

source base.sh

python3 run.py \
    +models=hyena \
    data.dataloader.batch_size=2 \
    trainer.accumulate_grad_batches=16 \
    trainer.optimizer.lr=6e-4 \
    data.dataloader.n_workers=10 \
    trainer.devices=[0,1] \
    model.config_kwargs.d_model=256 \
    model.config_kwargs.n_layer=4 \
    model.config_kwargs.max_seq_len=1024 \
    data.dataloader.max_length=1024 \
    main.path_to_output_dir=/share/pi/nigam/suhana/hf_ehr/cache/runs/hyena-8k-v8/ \
    logging.wandb.name=hyena-8k-v8