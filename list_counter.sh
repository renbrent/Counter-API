for x in $(curl -s http://localhost/counter); do
    curl -s http://localhost/counter/${x}
done
read