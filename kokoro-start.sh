set -e
[ -n "$KOKORO_API_KEY" ] || { echo "KOKORO_API_KEY is empty, refusing to start"; exit 1; }
export API_KEYS="[\"$KOKORO_API_KEY\"]"
export PORT=8080
export API_LOG_LEVEL="${API_LOG_LEVEL:-INFO}"
export DOWNLOAD_MODEL="${DOWNLOAD_MODEL:-false}"
# torch starts one thread per host core; on a CPU-limited container that
# oversubscribes the quota and slows speech 50x. Use the CPU limit, at most 8 threads.
if [ -z "$OMP_NUM_THREADS" ]; then
  n=""
  if [ -r /sys/fs/cgroup/cpu.max ]; then
    read -r q p < /sys/fs/cgroup/cpu.max || true
    [ "$q" != "max" ] && [ -n "$p" ] && n=$(( (q + p - 1) / p ))
  fi
  [ -n "$n" ] || n=$(nproc)
  [ "$n" -gt 8 ] && n=8
  [ "$n" -lt 1 ] && n=1
  export OMP_NUM_THREADS="$n"
fi
echo "cpus: nproc=$(nproc) cpu.max=$(cat /sys/fs/cgroup/cpu.max 2>/dev/null || echo n/a) OMP_NUM_THREADS=$OMP_NUM_THREADS"
exec ./entrypoint.sh
