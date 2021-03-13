const express = require('express')
const app = express()
const port = 3000

const name = 'Josh';

if (process.env.ENVIRONMENT === 'local' || process.env.ENVIRONMENT === 'interview') {
  try {
    const cors = require('cors');
    app.use(cors());
    app.options('*', cors());
  } catch (e) {
    console.log(e);
  }
}

app.get('/', (req, res) => {
  let time = Date.now().toString();
  res.send(JSON.stringify({ name, time }));
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})
