
Command line instructions
-----------------------------------------------------------------------------------------
Git global setup  
git config --global user.name "Name"  
git config --global user.email "e-mail"  

Create a new repository
-----------------------------------------------------------------------------------------
git clone https://github.com/Gugatb/classifier.git  
cd playlist  
touch README.md  
git add README.md  
git commit -m "add README"  
git push -u origin master  

Existing folder
-----------------------------------------------------------------------------------------
cd existing_folder  
git init  
git remote add origin https://github.com/Gugatb/classifier.git  
git add .  
git commit -m "Initial commit"  
git push -u origin master  

Existing Git repository
-----------------------------------------------------------------------------------------
cd existing_repo  
git remote rename origin old-origin  
git remote add origin https://github.com/Gugatb/classifier.git  
git push -u origin --all  
git push -u origin --tags  

SSH key
-----------------------------------------------------------------------------------------
ssh-keygen -t rsa -b 4096 -C "e-mail"  
eval $(ssh-agent -s)  
ssh-add id_rsa  
