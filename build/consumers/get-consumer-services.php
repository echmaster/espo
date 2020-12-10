<?php
// Скрипт читает настройки RMQ из файла rmq.php и возвращает в stdout строку с именами сервисов разделенных пробелом
$rmqConf = require __DIR__.'/rmq.php';

$consumersConf = $rmqConf['consumers'];

$serviceNames = array_map(
    function ($consumerSection) {
        return sprintf('comc-consumer@%s.service', $consumerSection['name']);
    }, $consumersConf
);

$serviceFilePath = __DIR__.'/consumer-guard.service';
$templateFilePath = $serviceFilePath.'.template';

$serviceTemplate = file_get_contents($templateFilePath);
$replace = "# Строка Requires сгенерирована автоматически\nRequires=".join($serviceNames, " ");
$serviceContent = str_replace('${Requires}', $replace, $serviceTemplate);
echo $serviceContent;
