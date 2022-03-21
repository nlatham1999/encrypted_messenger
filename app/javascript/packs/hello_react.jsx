// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import { useEffect, useState } from "react";
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { Card, Modal, Button, Container, Form, Row, Col } from "react-bootstrap";
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
  

  useEffect(() => {
      // getKeyPair()
  }, [])

  let getKeyPair = async () => {
    let res = await fetch("http://localhost:3000/ecdsa", {
        method: "GET",
        headers: {
        "Content-Type": "application/json",
        },
    });
    let keyPair = await res.json();
    setPrivateKey(keyPair.message.private_key)
    setAddress(keyPair.message.address)
  }

  let postEnteredMessage = async () => {
    console.log(postMessage)
    let res = await fetch("http://localhost:3000/send", {
        method: "POST",
        headers: {
        "Content-Type": "application/json",
        },
        body: JSON.stringify({
          "private_key": privateKey,
          "address": address,
          "pass_phrase": postPassPhrase,
          "message": postMessage,
        })
    });
    res = await res.json();
    try{
      console.log(res.message.id["$oid"])
      setPostMessageId(res.message.id["$oid"])
    }
    catch {
      console.log("whoops")
    }
  }

  let getUserMessage = async () => {
    let id = getMessageId.toString()
    let pass = getPassPhrase.toString()
    let res = await fetch("http://localhost:3000/receive?pass_phrase="+pass+"&message_id="+id, {
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
    }
  }
  

  return (
    <div className='wholePage'>
      <Container  className='overall'>
        <h1 className='generalHeaders topHeader'>encrypted messaging api</h1>
        <p className='generalText'>created by <a href="https://nicholaslatham.com">nick latham</a></p>
        <p><a href="#testing">test this api</a></p>
        <h2 className='generalHeaders'>how it works</h2>
        <div className='generalText'>
          <p>you can post messages with a pass phrase and anyone with that pass phrase will be able to view that message</p>
          <p>messages are encrypted using PKCS5</p>
          <p>authentication of the sender is done with the ECDSA signature algorithm using the secp256k1 curve (same as Bitcoin)</p>
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
                    onChange={(event) => {setUserPrivateKey(event.target.value)}}
                />
            </Form.Group>
            
            <Form.Group className='formSection'>
                <Form.Label >address</Form.Label>
                <Form.Control 
                    onChange={(event) => {setUserAddress(event.target.value)}}
                />
            </Form.Group>

            <Form.Group className='formSection'>
                <Form.Label >pass phrase</Form.Label>
                <Form.Control 
                    onChange={(event) => {setPostPassPhrase(event.target.value)}}
                />
            </Form.Group>

            <Form.Group className='formSection'>
                <Form.Label >message</Form.Label>
                <Form.Control 
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
                    onChange={(event) => {setGetMessageId(event.target.value)}}
                />
            </Form.Group>
            <Form.Group className='formSection'>
                <Form.Label >pass phrase</Form.Label>
                <Form.Control 
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
