#!/bin/bash
reportFolder=php_syntax_and_compatibility_reports
phpFiles=$(pwd)
report=$(pwd)/$reportFolder
script=$(pwd)/script
#menu
while (true)
do
    clear
    echo "Select the PHP version: (default php 7.0)"
    echo " "
    echo " 1 - php 5.6"
    echo " 2 - php 7.0"
    echo " 3 - php 7.1"
    echo " 4 - php 7.2"
    echo " 5 - php 7.3"
    echo " 6 - quit"
    read n
    case $n in
        1) version=5.6; break;;
        2) version=7.0; break;;
        3) version=7.1; break;;
        4) version=7.2; break;;
        5) version=7.3; break;;
        *) version=7.0; break;;
    esac
done


echo "PHP version selected: " $version

fullReportFile=phpSyntaxCheck-FullReport-php-$version.txt
errorReportFile=phpSyntaxCheck-ErrorsReport-php-$version.txt
coSnifferReportFile=codeSnifferReport-php-$version.txt

#Generate Script for PHP lint
mkdir script
echo " "
echo "Generating script for php lint"
echo "#!/bin/bash
echo \" \"
echo \"starting scan...\" 
echo \" \"
php -v 
echo \" \" &
if [ -e Report/$fullReportFile ]
then
    rm -f Report/$fullReportFile
    rm -f Report/$errorReportFile
fi
touch Report/$fullReportFile
touch Report/$errorReportFile
tail -f Report/$fullReportFile &
task(){
   php -l \$1 >> Report/$fullReportFile 2>> Report/$errorReportFile; 
}

N=10
 (for thing in \$(find . -type f \( -name \"*.php\" -or -name \"*.phtml\" \)) ; do 
   ((i=i%N)); ((i++==0)) && wait
   task \"\$thing\" & 
done
)
echo \" \"
echo \"Scan done successfully\"
echo \" \"" > script/phpSyntaxCheck-php-$version.sh
echo "Script generated successfully"

#Generate Dockerfile with php version selected
echo " "
echo "Generating Dockerfile with php $version"
echo "FROM ubuntu:18.04
LABEL maintainer==\"rimomcosta@gmail.com\"

RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    software-properties-common -y \
    --no-install-recommends \
    && add-apt-repository ppa:ondrej/php

ENV TZ=Europe/Dublin
RUN ln -snf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone

RUN apt-get update \
    && apt-get install -y \
    php$version-cli -y

RUN mkdir -p /script/phpFiles
RUN mkdir /Report

ENTRYPOINT [\"/bin/bash\"]
CMD [\"/script/phpSyntaxCheck-php-$version.sh\"]" > Dockerfile
echo "Dockerfile generated successfully"
echo " "

#generate dockerignore file
echo "*" > .dockerignore

#Build docker image
docker build -t php_syntax_check .

#Run the container for php-lint
docker run --name php_syntax_check -ti -v $phpFiles:/script/phpFiles -v $report:/Report -v $script:/script php_syntax_check

echo "docker container removed successfully"
echo " "
echo "PHP lint reports saved on dir '$report'"
echo " "

#php compatibility check from https://github.com/fortrabbit/phpco-docker
echo "Starting PHP compatibilty check"
phpco() { docker run --init --name phpcs_container -v $PWD:/mnt/src:cached --rm -u "$(id -u):$(id -g)" frbit/phpco:latest $@; return $?; }
phpco -p --colors --extensions=php --runtime-set testVersion $version -d memory_limit=1024M --warning-severity=0 --report-file=$reportFolder/$coSnifferReportFile . 

#Full clean up
rm -f Dockerfile 
rm -f .dockerignore
rm -r script
docker rm php_syntax_check

echo " "
echo "All done! thx"
echo " "