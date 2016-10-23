const WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({ port: 8080 });
const Koa = require('koa');
const serve = require('koa-static');
const mount = require('koa-mount');

const app = new Koa();

const MOVE_LEFT = 'moveLeft';
const MOVE_RIGHT= 'moveRight';
let position = 0;

wss.broadcast = data => {
  wss.clients.forEach( client => {
    client.send(data);
  });
}

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log(message);
    const { type } = JSON.parse(message);
    switch(type) {
      case MOVE_LEFT:
        position -= 1;
        break;
      case MOVE_RIGHT:
        position += 1;
        break;
      default:
        break;
    }
    wss.broadcast(JSON.stringify({ position }));
  });
});

app.use(mount('/', serve(__dirname + '/client')));
app.listen( process.env.PORT || 3000 )
