import logo from './logo.svg';
import './App.css';
import { useEffect, useState } from 'react';
import { Celebration } from './celebration/celebration'

function App() {

  const [btnText, setBtnText] = useState('Get your coupon now!');

  function getYourCoupon() {
    setBtnText('Please wait ..');
    fetch(
      process.env.REACT_APP_PRINT_API, {
      method: 'GET',
      headers: { 'Accept': 'application/pdf' }
    })
    .then( res => res.blob() )
    .then( blob => {
      var file = window.URL.createObjectURL(blob);
      window.location.assign(file);
    })
		.catch((error) => {
            setBtnText('Error Occurred');
        })
  };

  return (
    <div className='rca-container'>
      <div className='rca-box'>
        <div className='first-section'>
          <h1 className='d-none'>test</h1>
          <h1>Big Sale!</h1>
        </div>
        <div className='second-section'>
          <p>Up to <span className='percentage'>70%</span></p>
          <p>* valid until the end of the year</p>
          <button onClick={getYourCoupon}>{btnText}</button>
        </div>
      </div>
      <Celebration />
    </div>
  );
}

export default App;
