const express = require('express')
const app = express()
const port = 3000

const name = 'Josh';

if (process.env.ENVIRONMENT === 'local') {
  try {
    const cors = require('cors');
    app.use(cors());
    app.options('*', cors());
  } catch (e) {
    console.log(e);
  }
}

app.get('/', (req, res) => {
  console.log('hits');
  res.send(JSON.stringify({ name }));
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
