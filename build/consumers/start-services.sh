# перезапуск крон после старта
systemctl enable cron && systemctl restart cron && systemctl status cron
systemctl enable comc-countdown && systemctl start comc-countdown && systemctl status comc-countdown