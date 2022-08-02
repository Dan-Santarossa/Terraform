resource "null_resourse" "dummy_resource" {

#by default the provisioner is a create provisioner
#once the resourse has been created this will execute a bash command to echo "0" into a text file to signal complete   
provisioner "local-exec" {
    command = "echo '0' > status.txt"

}
#same function as before only on the destruction of resourses 
provisioner "local-exec" {
    when = destory 
    command = "echo '1' > status.txt"

  }
}