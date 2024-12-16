const express = require('express');
const axios = require('axios');
const dotenv = require('dotenv');
const bodyParser = require('body-parser');

dotenv.config();

const app = express();
app.use(bodyParser.json());

// Paystack Secret Key from .env
const PAYSTACK_SECRET_KEY = process.env.PAYSTACK_SECRET_KEY;

// Endpoint to receive Paystack callback
app.get('/paystack/callback', async (req, res) => {
  const reference = req.query.reference;

  if (!reference) {
    return res.status(400).json({ error: 'Reference parameter is missing.' });
  }

  try {
    // Verify the transaction with Paystack API
    const response = await axios.get(`https://api.paystack.co/transaction/verify/${reference}`, {
      headers: {
        Authorization: `Bearer ${PAYSTACK_SECRET_KEY}`,
      },
    });

    const transactionData = response.data.data;

    if (transactionData.status === 'success') {
      // Handle success - update your database, send notifications, etc.
      return res.status(200).json({ message: 'Payment was successful', data: transactionData });
    } else {
      // Handle failure - show an error or retry logic
      return res.status(400).json({ error: 'Payment failed', data: transactionData });
    }
  } catch (error) {
    console.error('Error verifying transaction:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
