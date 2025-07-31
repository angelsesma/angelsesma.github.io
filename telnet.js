const net = require('net');
const readline = require('readline');

const server = net.createServer((socket) => {
  socket.write('Welcome to CLI Terminal!\n');
  socket.write('Type "help" for commands\n> ');

  const rl = readline.createInterface({
    input: socket,
    output: socket,
    terminal: false
  });

  rl.on('line', (input) => {
    const command = input.trim().toLowerCase();
    
    switch(command) {
      case 'help':
        socket.write('Available: help, login, logout, exit, whoami\n');
        break;
      case 'login':
        socket.write('Usage: login <username> <password>\n');
        break;
      case 'exit':
        socket.write('Goodbye!\n');
        socket.end();
        return;
      default:
        socket.write(`Unknown command: ${command}\n`);
    }
    socket.write('> ');
  });

  socket.on('close', () => {
    console.log('Client disconnected');
  });
});

server.listen(23, () => {
  console.log('Telnet server running on port 23');
});