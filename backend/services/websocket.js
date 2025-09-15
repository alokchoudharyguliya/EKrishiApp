const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const Event = require('../models/event.js');
function setupWebSocket(server) {
  const wss = new WebSocket.Server({ server });
  const clients = new Map();
  return {
    broadcastEvents,
    sendEventsToClient
  };
}
// function formatDate(date) {
//   return new Date(date).toISOString().split('T')[0];
// }

module.exports = setupWebSocket;