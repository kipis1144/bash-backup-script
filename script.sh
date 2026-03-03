#!/bin/bash
 
if [ "$1" == "-h" ]; then
    echo "Использование: $0 <директория_источник> [директория_бэкапа]"
    exit 0
fi
 
if [ -z "$1" ]; then
    echo "Ошибка: укажите директорию для копирования."
    exit 1
fi
 
SOURCE_DIR="$1"
 
if [ -z "$2" ]; then
    BACKUP_DIR="$HOME/backups"
else
    BACKUP_DIR="$2"
fi
 
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Ошибка: директория не существует."
    exit 1
fi
 
mkdir -p "$BACKUP_DIR"
 
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | awk 'NR==2 {print $4}')
 
if [ "$AVAILABLE_SPACE" -lt 100000 ]; then
    echo "Недостаточно свободного места."
    exit 1
fi
 
RECENT_BACKUP=$(find "$BACKUP_DIR" -type f -name "*.tar.gz" -mmin -60)
 
if [ -n "$RECENT_BACKUP" ]; then
    echo "Бэкап уже создавался в течение последнего часа."
    exit 1
fi
 
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="backup_$DATE.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
 
tar -czf "$ARCHIVE_PATH" "$SOURCE_DIR" >> "$BACKUP_DIR/backup.log" 2>&1
 
if [ $? -ne 0 ]; then
    echo "Ошибка при создании архива."
    exit 1
fi
 
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm {} \;
 
FILE_COUNT=0
 
for file in "$SOURCE_DIR"/*; do
    if [ -f "$file" ]; then
        FILE_COUNT=$((FILE_COUNT + 1))
    fi
done
 
echo "Бэкап создан: $ARCHIVE_PATH"
echo "Количество файлов в директории: $FILE_COUNT"
