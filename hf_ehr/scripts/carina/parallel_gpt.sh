#!/bin/bash
#SBATCH --job-name=gpt_parallel
#SBATCH --output=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/gpt_parallel_%A.out
#SBATCH --error=/share/pi/nigam/mwornow/hf_ehr/slurm_logs/gpt_parallel_%A.err
#SBATCH --time=48:00:00
#SBATCH --partition=nigam-v100,gpu
#SBATCH --mem=200G
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:4

IS_FORCE_REFRESH=false

child_pids=()
stop_child_processes() {
    for pid in "${child_pids[@]}"; do
        pkill -P "$pid"
        kill "$pid"
    done
}

trap 'stop_child_processes' SIGTERM SIGINT

source base.sh

# Experiment names
RUN_NAMES=( "gpt-base-512--clmbr" "gpt-base-1024--clmbr" "gpt-base-2048--clmbr" "gpt-base-4096--clmbr" )
RUN_ARGS=(
    "gpt.sh base clmbr 512 approx"
    "gpt.sh base clmbr 1024 approx"
    "gpt.sh base clmbr 2048 approx"
    "gpt.sh base clmbr 4096 approx"
)

# Ensure that 1 <= len(RUN_ARGS) <= 5
if [ "${#RUN_ARGS[@]}" -le 0 ] || [ "${#RUN_ARGS[@]}" -ge 5 ]; then
    echo "Error: The length of RUN_ARGS should be between 1 and 4 (inclusive)."
    exit 1
fi

# Loop over the RUN_NAMES and args
for i in "${!RUN_NAMES[@]}"; do
    RUN_NAME=${RUN_NAMES[i]}
    RUN_ARG=${RUN_ARGS[i]}
    STDOUT=/share/pi/nigam/${USER}/hf_ehr/slurm_logs/${RUN_NAME}_${SLURM_JOB_ID}.out
    STDERR=/share/pi/nigam/${USER}/hf_ehr/slurm_logs/${RUN_NAME}_${SLURM_JOB_ID}.err
    echo "Launching job #${i} for '${RUN_NAME}' with args '${RUN_ARG}'"
    
    if [[ "$IS_FORCE_REFRESH" = true ]]; then
        # Overwrite
        EXTRA="+trainer.devices=[${i}] logging.wandb.name=${RUN_NAME} main.path_to_output_dir=/share/pi/nigam/$USER/hf_ehr/cache/runs/${RUN_NAME}_${SLURM_JOB_ID}/"
        bash $RUN_ARG "${EXTRA}" --is_force_refresh --is_skip_base > $STDOUT 2> $STDERR &
    else
        # Resume
        EXTRA="+trainer.devices=[${i}] logging.wandb.name=${RUN_NAME} main.path_to_output_dir=/share/pi/nigam/$USER/hf_ehr/cache/runs/${RUN_NAME}/"
        bash $RUN_ARG "${EXTRA}" --is_skip_base > $STDOUT 2> $STDERR &
    fi

    child_pids+=($!)
done

wait
