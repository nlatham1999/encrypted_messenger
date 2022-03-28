# Encrypted Message Posting API

located at https://encryptedposting.herokuapp.com/

## How it works
you post messages with a pass phrase and anyone with that pass phrase and message id will be able to view that message

messages are encrypted using PKCS5

authentication of the sender is done with the ECDSA signature algorithm using the secp256k1 curve (same as Bitcoin)

messages are stored in a centralized database using mongodb

## Endpoints 

### getting a keypair (GET)
https://encryptedposting.herokuapp.com/ecdsa

allows you to generate a private key and address so you can post messages

example output:
```
{
    "message": {
        "private_key": "9VvzzuBRadhanspDfrzCadajuDq4N8ma8YnUf5j2Q95Kiozwq",
        "address": "3BhjGNd7GPQtadajha1bPFVNG7k8k2i67Rn5Jo4GLLYLP6WYF"
    }
}
```

### adding a user (POST)

https://encryptedposting.herokuapp.com/add

add a user with a key pair

input:  
* private_key: the private key  
* address: the corresponding address  
* username: the username you want to use  

if you want to update your username, you can use this same endpoint

### generating a user (POST)

https://encryptedposting.herokuapp.com/generate

instead of generating a keypair and then adding a user, you can combine the two

input:  
* username: the username you want to use

example output:
```
{
    "message": {
        "private_key": "9VvzzuBRadhanspDfrzCadajuDq4N8ma8YnUf5j2Q95Kiozwq",
        "address": "3BhjGNd7GPQtadajha1bPFVNG7k8k2i67Rn5Jo4GLLYLP6WYF"
        "status_message": "added new record at 6241137134234adf0004b153109"
    }
}
```

### posting a message

https://encryptedposting.herokuapp.com/send

input:  
* message: the message you want encrypted and stored  
* private_key: the private key
* address: the address for the private key  
* pass_phrase: the pass phrase used to encrypt your message. must be at least 16 characters  
* message_type: an optional parameter to categorize the message

example output:


 
