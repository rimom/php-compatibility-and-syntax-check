# PHP compatibility and syntax check
Script to verify if your PHP code has the right syntax and if it is compatible with an specific version.

### Basically it runs *PHP lint* and *PHP Code Sniffer*

### Docker required

## How to execute:
1. Copy the file **php-check.sh** to the root of your project
2. Run `chmod +x php-check.sh`
3. Run `./php-check.sh`

At the end of the execution, a folder called **php_syntax_and_compatibility_reports** will be created with the reports in it 

#### It is not compatible with windows


##  This will perform:
1. Create a script called **phpSyntaxCheck-php-$version.sh** to run the php lint based on the choosen version and save it in **script**
2. Create a **Dockerfile** which will run the php version selected
3. Create a **.dockerignore** file to skip the verification of the other files when building up the container
4. Build the docker image with all necessary apps
5. Run the docker container and execute PHP lint
6. Starts the container for PHP Compatibility Check
7. Save the Report files
8. Clean upp all the created files

Feel free to change whatever you want
# php-compatibility-and-syntaxe-check
# php-compatibility-and-syntaxe-check
