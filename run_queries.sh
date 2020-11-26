echo "Get ordered tasks:"
echo ""
curl --header "Content-Type: application/json" --request POST --data '{"tasks": [{"name": "task-1","command": "touch /tmp/file1"},{"name": "task-2","command": "cat /tmp/file1","requires": ["task-3"]},{"name": "task-3","command": "echo Hello World! > /tmp/file1","requires": ["task-1"]},{"name": "task-4","command": "rm /tmp/file1","requires": ["task-2","task-3"]}]}' localhost:8080/order

echo ""
echo ""
echo "----------------------------------"

echo "Get script representation:"
echo ""
curl --header "Content-Type: application/json" --request POST --data '{"tasks": [{"name": "task-1","command": "touch /tmp/file1"},{"name": "task-2","command": "cat /tmp/file1","requires": ["task-3"]},{"name": "task-3","command": "echo Hello World! > /tmp/file1","requires": ["task-1"]},{"name": "task-4","command": "rm /tmp/file1","requires": ["task-2","task-3"]}]}' localhost:8080/script
echo ""
