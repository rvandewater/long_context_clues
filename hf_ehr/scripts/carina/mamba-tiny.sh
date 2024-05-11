#!/bin/bash
#SBATCH --job-name=mamba
#SBATCH --output=/share/pi/nigam/suhana/hf_ehr/cache/runs/slurm_logs/mamba_tiny.out
#SBATCH --error=/share/pi/nigam/suhana/hf_ehr/cache/runs/slurm_logs/mamba_tiny.err
#SBATCH --time=48:00:00
#SBATCH --partition=gpu
#SBATCH --mem=200G
#SBATCH --cpus-per-task=20
#SBATCH --gres=gpu:4

source base.sh

if [[ "$SLURM_JOB_PARTITION" == "nigam-a100" ]]; then
    echo "Detected A100 Partition"
    # TODO
elif [[ "$SLURM_JOB_PARTITION" == "nigam-v100" ]]; then
    echo "Detected V100 Partition"
    # TODO
elif [[ "$SLURM_JOB_PARTITION" == "gpu" ]]; then
    echo "Detected GPU Partition"
    # GPU Partition Settings (batch_size=6 fills GPUs up to about 31950 / 32768 MB)
    python3 ../run.py \
        +models=mamba \
        data.dataloader.mode=batch \
        data.dataloader.batch_size=2 \
        data.dataloader.approx_batch_sampler.max_tokens=2048 \
        trainer.accumulate_grad_batches=4 \
        data.dataloader.n_workers=10 \
        trainer.devices=[0] \
        model.config_kwargs.d_model=768 \
        model.config_kwargs.n_layer=24 \
        model.config_kwargs.num_hidden_layers=24 \
        data.dataloader.seq_length=1024 \
        callbacks.model_checkpointing.every_n_train_steps=100 \
        main.path_to_output_dir=/share/pi/nigam/suhana/hf_ehr/cache/runs/mamba-test/ \
        logging.wandb.name=mamba-tiny
else
    echo "Unknown SLURM partition: $SLURM_JOB_PARTITION"
    exit 1
fi

