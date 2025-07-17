const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// In-memory database for development
// In a production environment, you'd use a real database
const ideas = [];

// Routes
app.get('/', (req, res) => {
  res.send('Entrepreneur Journey API is running');
});

// MARK: - Business Ideas API

// Get all ideas
app.get('/v1/ideas', (req, res) => {
  console.log('Fetching all ideas, count:', ideas.length);
  
  // Ensure all ideas have the correct format
  const formattedIdeas = ideas.map(idea => ({
    id: idea.id || uuidv4(),
    description: idea.description || '',
    targetMarket: idea.targetMarket || '',
    effort: idea.effort || '',
    reward: idea.reward || '',
    date: idea.date || new Date().toISOString()
  }));
  
  res.json(formattedIdeas);
});

// Get a specific idea
app.get('/v1/ideas/:id', (req, res) => {
  console.log(`Fetching idea with ID: ${req.params.id}`);
  const idea = ideas.find(i => i.id === req.params.id);
  if (!idea) {
    return res.status(404).json({ error: 'Business idea not found' });
  }
  
  // Ensure consistent format
  const formattedIdea = {
    id: idea.id,
    description: idea.description || '',
    targetMarket: idea.targetMarket || '',
    effort: idea.effort || '',
    reward: idea.reward || '',
    date: idea.date || new Date().toISOString()
  };
  
  res.json(formattedIdea);
});

// Create a new idea
app.post('/v1/ideas', (req, res) => {
  const idea = req.body;
  console.log('Received idea:', JSON.stringify(idea));
  
  // Format the data to match the Swift model
  const formattedIdea = {
    id: idea.id || uuidv4(),
    description: idea.description || '',
    targetMarket: idea.targetMarket || '',
    effort: idea.effort || '',
    reward: idea.reward || '',
    date: idea.date || new Date().toISOString()
  };
  
  console.log('Formatted idea:', JSON.stringify(formattedIdea));
  ideas.push(formattedIdea);
  res.status(201).json(formattedIdea);
});

// Update an idea
app.put('/v1/ideas/:id', (req, res) => {
  console.log(`Updating idea with ID: ${req.params.id}`);
  console.log('Update data:', JSON.stringify(req.body));
  
  const index = ideas.findIndex(i => i.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Business idea not found' });
  }
  
  // Update the idea with new values, keeping the same ID
  const updatedIdea = {
    id: req.params.id,
    description: req.body.description || ideas[index].description || '',
    targetMarket: req.body.targetMarket || ideas[index].targetMarket || '',
    effort: req.body.effort || ideas[index].effort || '',
    reward: req.body.reward || ideas[index].reward || '',
    date: req.body.date || ideas[index].date || new Date().toISOString()
  };
  
  console.log('Formatted updated idea:', JSON.stringify(updatedIdea));
  ideas[index] = updatedIdea;
  res.json(updatedIdea);
});

// Delete an idea
app.delete('/v1/ideas/:id', (req, res) => {
  const index = ideas.findIndex(i => i.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Business idea not found' });
  }
  
  ideas.splice(index, 1);
  res.json({});
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
