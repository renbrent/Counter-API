for ((i=1;i<=100;i++)); do curl -s http://localhost/ ; done | sort | uniq
read