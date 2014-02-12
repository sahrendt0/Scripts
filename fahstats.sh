grep "Project" /var/lib/fahclient/log.txt | tail -n 1 | cut -d":" -f 7,8 | cut -d" " -f 1,2
grep "Completed" /var/lib/fahclient/log.txt | tail -n 1 | cut -d":" -f 7 | cut -d"(" -f 2 | cut -d")" -f 1
echo "Jobs: "
grep 100% /var/lib/fahclient/log.txt | wc -l
echo "Log started: "
head -1 /var/lib/fahclient/log.txt | cut -d" " -f 4 | cut -d"T" -f 1
head -1 /var/lib/fahclient/log.txt | cut -d" " -f 4 | cut -d"T" -f 2
