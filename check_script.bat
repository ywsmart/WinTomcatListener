@echo off
rem GBK
rem V1.1
rem echo off是批处理文件中的命令，可以使得下面的命令不在显示屏上面显示，前面加上@是为了使其本身不显示
rem setlocal是批处理本地化的一种操作，在执行setlocal之后所做的环境改动只限于批处理文件
rem ENABLEDELAYEDEXPANSION 启用变量延迟，直到出现匹配的endlocal命令
SETLOCAL ENABLEDELAYEDEXPANSION

Title Tomcat监听中...，请勿随意关闭...
rem rem的意思是注释
rem 链接
set URL="locahost"
rem 待验证http code，一般为200
set HTTP_CODE=0
rem tomcat的目录
set TOMCAT_HOME="Tomcat"
rem 设置配置文件路径,%~dp0为此bat文件路径
set "file=%~dp0\check_list.txt"
rem 设置重启标志
set ISRESART="n"

rem 每次检测完后等待时间（秒），再进行下一次检测，若将程序部署到系统计划任务，可忽略
set TIME_WAIT=100
rem 设置钉钉通知接口的token
rem set DINGDING_TOKEN=""
rem testToken
set DINGDING_TOKEN=""
rem 设置钉钉通知的信息，因此bat运行在GBK编码的cmd里，cmd切换UTF-8发送也乱码，而钉钉接口需要UTF-8，所以目前通知信息必须为英文(信息尾部的!将无法显示)
set DINGDING_MSG="msgErr"

REM echo string:将字符串显示在屏幕中
REM :loop 和下面的goto组合成循环，for内请不要使用goto，会使程序跳出全部for
echo [!date! !time!] Begin Checking Tomcat，请勿随意关闭...
:loop
    REM 打印时间 执行状态
    rem echo [!date! !time!] begin checking tomcat
    REM 将记录保存在日志文件中
    rem echo [!date! !time!] begin checking tomcat >>!LOG_PATH!
    rem 当前日期
    set dateStr=%date:~0,4%%date:~5,2%%date:~8,2%
    rem 日志文件的路径
    set LOG_PATH=%~dp0\!dateStr!checkerr.log
    rem 从配置文件获取待检验Tomcat的参数
    REM 循环
    rem FOR [参数] %%变量名 IN (相关文件或命令) DO 执行的命令
    rem 其中参数有/d /l /r /f
    rem 参数 /d (参数只能显示当前目录下的目录名字)
    rem 参数 /R (搜索指定路径及所有子目录中与set相符合的所有文件)
    rem 参数 /L (该集表示以增量形式从开始到结束的一个数字序列。可以使用负的 Step)
    rem 参数 /F (使用文件解析来处理命令输出、字符串及文件内容。)
    rem 参数 /F 的参数eol=# 指定一个行注释字符，遇到#开头的行就忽略掉
    rem 参数 /F 的参数delims=xxx 指定分隔符。默认是空格和TAB
    rem 参数 /F 的参数tokens=x,y,m-n 指每行的哪一个符号被传递到每个迭代
    rem 参数 /F 的参数usebackq 1.把单引号字符串作为命令；2.允许中使用双引号扩起文件名称。
    rem (相关文件或命令)指定一个或一组文件。可以使用通配符
    rem for内引用变量请用!param!的方式
    for /f "eol=# usebackq tokens=1-5 delims=|" %%a in ("!file!") do (
        set URL=%%a
        set HTTP_CODE=%%b
        set TOMCAT_HOME=%%c
        set DINGDING_MSG=%%d
        set ISRESART=%%e
        rem 调试log
        REM echo url:!URL! >>!LOG_PATH!
        REM echo HTTP_CODE:!HTTP_CODE! >>!LOG_PATH!
        REM echo TOMCAT_HOME:!TOMCAT_HOME! >>!LOG_PATH!
        REM echo DINGDING_MSG:!DINGDING_MSG! >>!LOG_PATH!
        REM echo ISRESART:!ISRESART! >>!LOG_PATH!

        rem 关闭tomcat命令的路径
        set CLOSE_BAT=!TOMCAT_HOME!\bin\shutdown.bat
        rem 启动tomcat命令的路径
        set START_BAT=!TOMCAT_HOME!\bin\startup.bat
        rem tomcat缓存目录
        set TOMCAT_CACHE=!TOMCAT_HOME!\work

        rem 设置code
        set httpcode=0
        rem 避免使用goto，改成如下逻辑
        rem 循环请求3次
        for /l %%i in (1,1,3) do (
            rem echo Check%%i 
            REM 借助curl工具获得项目的状态头
            for /f "delims=" %%r in ('curl -sL -w "%%{http_code}" !URL! -o /dev/null') do (
                REM 将变量r的值赋值给httpcode
                set httpcode=%%r
            )
            timeout -t 1 >nul
            rem 判断是否为目标httpcode
            if !httpcode!==!HTTP_CODE! (
                rem %%i为3才写log，为了减少log，可注释
                REM if "%%i"=="3" (
                rem echo the tomcat is running-!TOMCAT_HOME!
                rem echo [!date! !time!] StatusCode:!httpcode! the tomcat is running-!TOMCAT_HOME! >>!LOG_PATH!
                REM )
            ) else (
                rem 尝试请求错误到第3次，才通知并重启Tomcat
                if "%%i"=="3" (
                    echo [!date! !time!] ***ErrCode***=!httpcode!-!TOMCAT_HOME! >>!LOG_PATH!
                    REM 发送钉钉通知
                    curl "https://oapi.dingtalk.com/robot/send?access_token=!DINGDING_TOKEN!" -H "Content-Type:application/json;charset=utf-8" -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"!DINGDING_MSG!\"},\"at\":{\"isAtAll\":true}}" >nul
                    rem 判断是否需要重启
                    if "!ISRESART!"=="y" (
                        REM 打开Tomcat的bin目录
                        cd /d !TOMCAT_HOME!\bin
                        echo [!date! !time!] close tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM 关闭tomcat,call在批处理中用于调用另一个批处理文件，start用于执行一些外部程序
                        call !CLOSE_BAT!
                        timeout -t 10 >nul
                        REM 记录日志
                        echo [!date! !time!] success to close tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM 清除tomcatwork空间 /s意思是不需要确认的删除 /Q是清除目录及子目录
                        rd /S /Q !TOMCAT_CACHE!
                        echo [!date! !time!] start tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM 开启tomcat,执行bat文件
                        call !START_BAT!
                        rem 重启后验证访问
                        timeout -t 10 >nul
                        REM 借助curl工具获得项目的状态头
                        for /f "delims=" %%s in ('curl -sL -w "%%{http_code}" !URL! -o /dev/null') do (
                            REM 将变量r的值赋值给httpcode
                            set httpcode=%%s
                        )
                        if !httpcode!==!HTTP_CODE! (
                            curl "https://oapi.dingtalk.com/robot/send?access_token=!DINGDING_TOKEN!" -H "Content-Type:application/json;charset=utf-8" -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"Restart Success,Tomcat is running.\"},\"at\":{\"isAtAll\":true}}" >nul
                            echo success to start tomcat-!TOMCAT_HOME!
                            echo [!date! !time!] success to start tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        )
                    )
                )
            )
        )
    )
    timeout -t 1 >nul
    rem echo [!date! !time!] finish checking tomcat
    rem echo [!date! !time!] finish checking tomcat >>!LOG_PATH!
    rem 若将脚本程序部署到系统计划程序中，将以下代码可注释
    timeout -t !TIME_WAIT! >nul
goto loop