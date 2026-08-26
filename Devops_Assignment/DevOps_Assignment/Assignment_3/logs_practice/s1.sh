#!/bin/bash
echo "=== 1. Count CSV files ==="
ls *.csv | wc -l

echo "=== 2. Line counts ==="
wc -l *.csv
cat *.csv | wc -l

echo "=== 3. Name and region from sales_jan.csv ==="
cut -d',' -f2,3 sales_jan.csv

echo "=== 4. Active with salary > 40000 ==="
awk -F',' '$5=="Active" && $4>40000' sales_*.csv

echo "=== 5. Names starting with vowels ==="
awk -F',' 'tolower($2) ~ /^[aeiou]/ {print $2}' sales_*.csv

echo "=== 6. Replace Inactive with Terminated ==="
sed 's/Inactive/Terminated/g' sales_*.csv

echo "=== 7. Unique regions count ==="
cut -d',' -f3 sales_*.csv | sort -u | wc -l

echo "=== 8. Trimmed active count ==="
cat sales_*.csv | awk -F',' '$5=="Active"' | sed 's/^[^,]*,//' | wc -l
