#!/usr/bin/env bash
# 本地模拟 CI：一条命令 = 日志 + Fastlane 测试 + 归档本次执行记录
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RUN_ID="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="fastlane/test_output/runs/${RUN_ID}"
mkdir -p "$RUN_DIR"

LOG_FILE="${RUN_DIR}/run.log"
SUMMARY_FILE="${RUN_DIR}/summary.txt"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo " CICD_Demo — Local CI"
echo " Run ID:   ${RUN_ID}"
echo " Started:  $(date '+%Y-%m-%d %H:%M:%S')"
echo " Project:  ${ROOT}"
echo "=========================================="

if command -v git &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Git branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
  echo "Git commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
else
  echo "Git: (not a git repository — skip)"
fi

echo ""
echo ">>> Step 1/1: fastlane test (CI gate)"
echo ""

START_TS=$(date +%s)
EXIT_CODE=0

if [[ -f Gemfile ]] && command -v bundle &>/dev/null && bundle check &>/dev/null; then
  bundle exec fastlane test || EXIT_CODE=$?
elif command -v fastlane &>/dev/null; then
  fastlane test || EXIT_CODE=$?
else
  echo "ERROR: fastlane not found. Run: gem install fastlane  OR  bundle install"
  exit 127
fi

END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))

echo ""
echo ">>> Archiving reports to ${RUN_DIR}"

for f in report.html report.junit; do
  if [[ -f "fastlane/test_output/${f}" ]]; then
    cp "fastlane/test_output/${f}" "${RUN_DIR}/${f}"
  fi
done

if [[ -d "fastlane/test_output/CICD_Demo.xcresult" ]]; then
  cp -R "fastlane/test_output/CICD_Demo.xcresult" "${RUN_DIR}/CICD_Demo.xcresult"
fi

{
  echo "run_id=${RUN_ID}"
  echo "finished=$(date '+%Y-%m-%d %H:%M:%S')"
  echo "duration_seconds=${DURATION}"
  echo "exit_code=${EXIT_CODE}"
  echo "log=${LOG_FILE}"
  echo "html_report=${RUN_DIR}/report.html"
  echo "junit_report=${RUN_DIR}/report.junit"
} > "$SUMMARY_FILE"

echo ""
echo "=========================================="
echo " Local CI finished"
echo " Exit code:  ${EXIT_CODE}  ($([[ ${EXIT_CODE} -eq 0 ]] && echo SUCCESS || echo FAILED))"
echo " Duration:   ${DURATION}s"
echo " Summary:    ${SUMMARY_FILE}"
echo " Log:        ${LOG_FILE}"
echo " HTML:       ${RUN_DIR}/report.html"
echo "=========================================="

exit "${EXIT_CODE}"
