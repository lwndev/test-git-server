Test Git Server
===================

Creates an configures an Ubuntu 12.04 server with a bare git repository and a post-receive hook that will deploy to the webroot of an Apache web server.

## Notes

1. You'll need to have Git, Vagrant 1.1+ and VirtualBox installed to get this to work
2. The Apache virtual host on the VM is configured to use the domain http://gitserver.local. You'll need to define this in your hosts file OR you can use the IP address of the Vagrant box (192.168.66.10) 
3. This proof of concept only supports serving static HTML files at this time.  No PHP, Server-Side Includes, etc.

## Dependencies

1. [Vagrant](http://downloads.vagrantup.com/)
2. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
3. [Git](http://git-scm.com/)
4. An existing Git project configured with the file structure: /src/www

Example: You'll need a project with this directory structure for this proof of concept to work

/project-folder
  /src
    /www
      index.html

## Usage

Clone the repo and create/startup the Vagrant box

        $ git clone https://github.com/lwndev/test-git-server.git && cd test-git-server
        $ vagrant up
   
Note: Wait until the box is up and running and Puppet has completed its provisioning before moving to the next step.

Add the git repository on the Vagrant box as a remote for your local git project

        $ git remote add webserver ssh://vagrant@192.168.66.10/home/vagrant/site.git
        $ git push webserver +master:refs/heads/master
    
This will tranfer the contents of your project to the git repo on the VM and a post-receive hook will deploy the 

Open your web browser and navigate to the following URL and you'll see the contents of your src/www directory

        http://192.168.66.10
