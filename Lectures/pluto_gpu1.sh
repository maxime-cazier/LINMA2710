#!/bin/bash
#SBATCH --job-name=pluto_gpu1
#SBATCH --ntasks=1
#SBATCH --time=2:00:00
#SBATCH --mem-per-cpu=10000
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1

ip=$(hostname -i)
echo "Run \$ sshuttle -r $CLUSTER_NAME $ip/16"
julia --project -e 'import Pkg; Pkg.instantiate()'
julia --project -e "import Pluto; Pluto.run(host=\"$ip\", port=1234, launch_browser=false)"
