// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import { useEffect, useState } from "react";
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { Card, Alert, Modal, Button, Container, Form, Row, Col } from "react-bootstrap";
import 'bootstrap/dist/css/bootstrap.min.css';

function Hello () {
  // <div>Hello {props.name}!</div>

  const [privateKey, setPrivateKey] = useState("")
  const [address, setAddress] = useState("")
  const [userPrivateKey, setUserPrivateKey] = useState("")
  const [userAddress, setUserAddress] = useState("")
  const [postPassPhrase, setPostPassPhrase] = useState("")
  const [postMessage, setPostMessage] = useState("")
  const [postMessageId, setPostMessageId] = useState("")
  const [getMessageId, setGetMessageId] = useState("")
  const [getPassPhrase, setGetPassPhrase] = useState("")
  const [getMessage, setGetMessage] = useState("")
  const [showAlert, setShowAlert] = useState(false)
  const [alertMessage, setAlertMessage] = useState("")
  

  useEffect(() => {
      // getKeyPair()
  }, [])

  let getKeyPair = async () => {
    let res = await fetch("https://encryptedposting.herokuapp.com/ecdsa", {
        method: "GET",
        headers: {
        "Content-Type": "application/json",
        },
    });
    let keyPair = await res.json();
    setPrivateKey(keyPair.message.private_key)
    setAddress(keyPair.message.address)
    setUserPrivateKey(keyPair.message.private_key)
    setUserAddress(keyPair.message.address)
  }

  let postEnteredMessage = async () => {
    if(userPrivateKey.length == 0 || userAddress.length == 0 || postPassPhrase.length == 0 || postMessage.length == 0){
      setAlertMessage("missing parameters")
      setShowAlert(true)
    }
    console.log(postMessage)
    let res = await fetch("https://encryptedposting.herokuapp.com/send", {
        method: "POST",
        headers: {
        "Content-Type": "application/json",
        },
        body: JSON.stringify({
          "private_key": userPrivateKey,
          "address": userAddress,
          "pass_phrase": postPassPhrase,
          "message": postMessage,
        })
    });
    res = await res.json();
    try{
      console.log(res.message.id["$oid"])
      setPostMessageId(res.message.id["$oid"])
      setGetPassPhrase(postPassPhrase)
      setGetMessageId(res.message.id["$oid"])
    }
    catch {
      console.log("whoops")
      console.log(res)
      try{
        setAlertMessage(res.errors[0].title)
        setShowAlert(true)
      }catch{

      }
    }
  }

  let getUserMessage = async () => {
    if(getMessageId.length == 0 || getPassPhrase.length == 0){
      setAlertMessage("missing parameters")
      setShowAlert(true)
    }
    let id = getMessageId.toString()
    let pass = getPassPhrase.toString()
    let res = await fetch("https://encryptedposting.herokuapp.com/receive?pass_phrase="+pass+"&message_id="+id, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
    });
    res = await res.json();
    try{
      setGetMessage(res.message)
    }catch{
      console.log("whoops")
      console.log(res)
      try{
        setAlertMessage(res.errors[0].title)
        setShowAlert(true)
      }catch{

      }
    }
  }
  

  return (
    <div className='wholePage'>
      {showAlert && <Alert variant="danger" onClose={() => setShowAlert(false)} dismissible>
        <Alert.Heading>error</Alert.Heading>
        <p>
          {alertMessage}
        </p>
      </Alert>}
      <Container  className='overall'>
        <h1 className='generalHeaders topHeader'>encrypted messaging api</h1>
        <p className='generalText'>created by <a href="https://nicholaslatham.com">nick latham</a></p>
        <p><a href="#testing">test this api</a></p>
        <h2 className='generalHeaders'>how it works</h2>
        <div className='generalText'>
          <p>you post messages with a pass phrase and anyone with that pass phrase and message id will be able to view that message</p>
          <p>messages are encrypted using PKCS5</p>
          <p>authentication of the sender is done with the ECDSA signature algorithm using the secp256k1 curve (same as Bitcoin)</p>
          <p>messages are stored in a centralized database using mongodb (like decentralized but faster and better). </p>
          <p>created using Ruby (backend) with React (frontend) and lots of tlc</p>
        </div>

        <h2 className='generalHeaders'>posting a message: /send</h2>
        <div className='generalText'>
          <p>parameters</p>
          <ul>
              <li>message: the message you want encrypted and stored</li>
              <li>private_key: the private key in base 58 </li>
              <li>address: the address which is the public key that has been hashed using SHA256 and then converted to base 58</li>
              <li>pass_phrase: the pass phrase used to encrypt your message. must be at least 16 characters</li>
          </ul>
        </div>
    
        <h2 className='generalHeaders'>getting a key pair: /ecdsa</h2>
        <p className='generalText'>output: private key in base 58, public key hashed using SHA256 and in base 58</p>
    
        <h2 className='generalHeaders'>getting a message /receive</h2>
        <div className='generalText'>
          <p>parameters</p>
          <ul>
              <li>message_id: the id of the message</li>
              <li>pass_phrase: the pass phrase used to encrypt your message. must be at least 16 characters</li>
          </ul>
        </div>
        
        <h1 id="testing" className='generalHeaders topHeader'>testing</h1>

        <Card className='cardSection'>
          <Card.Header>
            <Row>
              <Col>
                create private key and address
              </Col>
              <Col className='button'>
                <Button onClick={()=>getKeyPair()} >click here to generate</Button>
              </Col>
            </Row> 
          </Card.Header>
          <Card.Body>
            private key: {privateKey}<br></br>
            address: {address}
          </Card.Body>
        </Card>

        <Card className='cardSection'>
          <Card.Header>
            <Row>
              <Col>
                posting a message
              </Col>
              <Col className='button'>
                <Button onClick={() => postEnteredMessage()}>click here to post message</Button>
              </Col>
            </Row>
          </Card.Header>
          <Card.Body>
            <Form.Group className='formSection'>
                <Form.Label >private key</Form.Label>
                <Form.Control 
                    defaultValue={privateKey} 
                    onChange={(event) => {setUserPrivateKey(event.target.value)}}
                />
            </Form.Group>
            
            <Form.Group className='formSection'>
                <Form.Label >address</Form.Label>
                <Form.Control 
                    defaultValue={address} 
                    onChange={(event) => {setUserAddress(event.target.value)}}
                />
            </Form.Group>

            <Form.Group className='formSection'>
                <Form.Label >pass phrase</Form.Label>
                <Form.Control 
                    placeholder={"your passphrase e.g.(the red dog runs fast)"}
                    onChange={(event) => {setPostPassPhrase(event.target.value)}}
                />
            </Form.Group>

            <Form.Group className='formSection'>
                <Form.Label >message</Form.Label>
                <Form.Control 
                    placeholder={"your message"}
                    onChange={(event) => {setPostMessage(event.target.value)}}
                />
            </Form.Group>

            new message id: {postMessageId}
          </Card.Body>

        </Card>
        <Card className='cardSection'>
          <Card.Header>
            <Row>
              <Col>
                  get message 
              </Col>
              <Col className='button'>
                  <Button onClick={() => getUserMessage()}>click here to get message </Button>
              </Col>
            </Row>
          </Card.Header>
          <Card.Body>
            <Form.Group className='formSection'>
                <Form.Label >message id</Form.Label>
                <Form.Control 
                    defaultValue={postMessageId} 
                    onChange={(event) => {setGetMessageId(event.target.value)}}
                />
            </Form.Group>
            <Form.Group className='formSection'>
                <Form.Label >pass phrase</Form.Label>
                <Form.Control 
                    defaultValue={postPassPhrase} 
                    onChange={(event) => {setGetPassPhrase(event.target.value)}}
                />
            </Form.Group>

            message: {getMessage}

          </Card.Body>
        </Card>

      </Container>
  
      
    </div>
  );
}

// Hello.defaultProps = {
//   name: 'David'
// }

Hello.propTypes = {
  name: PropTypes.string
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Hello name="React" />,
    document.body.appendChild(document.createElement('div')),
  )
})
