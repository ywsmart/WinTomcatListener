@echo off
rem GBK
rem V1.1
rem echo off���������ļ��е��������ʹ��������������ʾ��������ʾ��ǰ�����@��Ϊ��ʹ�䱾����ʾ
rem setlocal���������ػ���һ�ֲ�������ִ��setlocal֮�������Ļ����Ķ�ֻ�����������ļ�
rem ENABLEDELAYEDEXPANSION ���ñ����ӳ٣�ֱ������ƥ���endlocal����
SETLOCAL ENABLEDELAYEDEXPANSION

Title Tomcat������...����������ر�...
rem rem����˼��ע��
rem ����
set URL="locahost"
rem ����֤http code��һ��Ϊ200
set HTTP_CODE=0
rem tomcat��Ŀ¼
set TOMCAT_HOME="Tomcat"
rem ���������ļ�·��,%~dp0Ϊ��bat�ļ�·��
set "file=%~dp0\check_list.txt"
rem ����������־
set ISRESART="n"

rem ÿ�μ�����ȴ�ʱ�䣨�룩���ٽ�����һ�μ�⣬����������ϵͳ�ƻ����񣬿ɺ���
set TIME_WAIT=100
rem ���ö���֪ͨ�ӿڵ�token
rem set DINGDING_TOKEN=""
rem testToken
set DINGDING_TOKEN=""
rem ���ö���֪ͨ����Ϣ�����bat������GBK�����cmd�cmd�л�UTF-8����Ҳ���룬�������ӿ���ҪUTF-8������Ŀǰ֪ͨ��Ϣ����ΪӢ��(��Ϣβ����!���޷���ʾ)
set DINGDING_MSG="msgErr"

REM echo string:���ַ�����ʾ����Ļ��
REM :loop �������goto��ϳ�ѭ����for���벻Ҫʹ��goto����ʹ��������ȫ��for
echo [!date! !time!] Begin Checking Tomcat����������ر�...
:loop
    REM ��ӡʱ�� ִ��״̬
    rem echo [!date! !time!] begin checking tomcat
    REM ����¼��������־�ļ���
    rem echo [!date! !time!] begin checking tomcat >>!LOG_PATH!
    rem ��ǰ����
    set dateStr=%date:~0,4%%date:~5,2%%date:~8,2%
    rem ��־�ļ���·��
    set LOG_PATH=%~dp0\!dateStr!checkerr.log
    rem �������ļ���ȡ������Tomcat�Ĳ���
    REM ѭ��
    rem FOR [����] %%������ IN (����ļ�������) DO ִ�е�����
    rem ���в�����/d /l /r /f
    rem ���� /d (����ֻ����ʾ��ǰĿ¼�µ�Ŀ¼����)
    rem ���� /R (����ָ��·����������Ŀ¼����set����ϵ������ļ�)
    rem ���� /L (�ü���ʾ��������ʽ�ӿ�ʼ��������һ���������С�����ʹ�ø��� Step)
    rem ���� /F (ʹ���ļ���������������������ַ������ļ����ݡ�)
    rem ���� /F �Ĳ���eol=# ָ��һ����ע���ַ�������#��ͷ���оͺ��Ե�
    rem ���� /F �Ĳ���delims=xxx ָ���ָ�����Ĭ���ǿո��TAB
    rem ���� /F �Ĳ���tokens=x,y,m-n ָÿ�е���һ�����ű����ݵ�ÿ������
    rem ���� /F �Ĳ���usebackq 1.�ѵ������ַ�����Ϊ���2.������ʹ��˫���������ļ����ơ�
    rem (����ļ�������)ָ��һ����һ���ļ�������ʹ��ͨ���
    rem for�����ñ�������!param!�ķ�ʽ
    for /f "eol=# usebackq tokens=1-5 delims=|" %%a in ("!file!") do (
        set URL=%%a
        set HTTP_CODE=%%b
        set TOMCAT_HOME=%%c
        set DINGDING_MSG=%%d
        set ISRESART=%%e
        rem ����log
        REM echo url:!URL! >>!LOG_PATH!
        REM echo HTTP_CODE:!HTTP_CODE! >>!LOG_PATH!
        REM echo TOMCAT_HOME:!TOMCAT_HOME! >>!LOG_PATH!
        REM echo DINGDING_MSG:!DINGDING_MSG! >>!LOG_PATH!
        REM echo ISRESART:!ISRESART! >>!LOG_PATH!

        rem �ر�tomcat�����·��
        set CLOSE_BAT=!TOMCAT_HOME!\bin\shutdown.bat
        rem ����tomcat�����·��
        set START_BAT=!TOMCAT_HOME!\bin\startup.bat
        rem tomcat����Ŀ¼
        set TOMCAT_CACHE=!TOMCAT_HOME!\work

        rem ����code
        set httpcode=0
        rem ����ʹ��goto���ĳ������߼�
        rem ѭ������3��
        for /l %%i in (1,1,3) do (
            rem echo Check%%i 
            REM ����curl���߻����Ŀ��״̬ͷ
            for /f "delims=" %%r in ('curl -sL -w "%%{http_code}" !URL! -o /dev/null') do (
                REM ������r��ֵ��ֵ��httpcode
                set httpcode=%%r
            )
            timeout -t 1 >nul
            rem �ж��Ƿ�ΪĿ��httpcode
            if !httpcode!==!HTTP_CODE! (
                rem %%iΪ3��дlog��Ϊ�˼���log����ע��
                REM if "%%i"=="3" (
                rem echo the tomcat is running-!TOMCAT_HOME!
                rem echo [!date! !time!] StatusCode:!httpcode! the tomcat is running-!TOMCAT_HOME! >>!LOG_PATH!
                REM )
            ) else (
                rem ����������󵽵�3�Σ���֪ͨ������Tomcat
                if "%%i"=="3" (
                    echo [!date! !time!] ***ErrCode***=!httpcode!-!TOMCAT_HOME! >>!LOG_PATH!
                    REM ���Ͷ���֪ͨ
                    curl "https://oapi.dingtalk.com/robot/send?access_token=!DINGDING_TOKEN!" -H "Content-Type:application/json;charset=utf-8" -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"!DINGDING_MSG!\"},\"at\":{\"isAtAll\":true}}" >nul
                    rem �ж��Ƿ���Ҫ����
                    if "!ISRESART!"=="y" (
                        REM ��Tomcat��binĿ¼
                        cd /d !TOMCAT_HOME!\bin
                        echo [!date! !time!] close tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM �ر�tomcat,call�������������ڵ�����һ���������ļ���start����ִ��һЩ�ⲿ����
                        call !CLOSE_BAT!
                        timeout -t 10 >nul
                        REM ��¼��־
                        echo [!date! !time!] success to close tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM ���tomcatwork�ռ� /s��˼�ǲ���Ҫȷ�ϵ�ɾ�� /Q�����Ŀ¼����Ŀ¼
                        rd /S /Q !TOMCAT_CACHE!
                        echo [!date! !time!] start tomcat-!TOMCAT_HOME! >>!LOG_PATH!
                        REM ����tomcat,ִ��bat�ļ�
                        call !START_BAT!
                        rem ��������֤����
                        timeout -t 10 >nul
                        REM ����curl���߻����Ŀ��״̬ͷ
                        for /f "delims=" %%s in ('curl -sL -w "%%{http_code}" !URL! -o /dev/null') do (
                            REM ������r��ֵ��ֵ��httpcode
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
    rem �����ű�������ϵͳ�ƻ������У������´����ע��
    timeout -t !TIME_WAIT! >nul
goto loop