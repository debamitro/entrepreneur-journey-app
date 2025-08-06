import express = require('express');
import cors = require('cors');
import bodyParser = require('body-parser');
import { PrismaClient } from '@prisma/client';

type Request = express.Request;
type Response = express.Response;

// Initialize Prisma Client
const prisma = new PrismaClient();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Define the BusinessIdea interface (matching Prisma model)
interface BusinessIdea {
  id: string;
  description: string;
  targetMarket: string;
  effort: string;
  reward: string;
  date: string;
  createdAt: Date;
  updatedAt: Date;
}

// Routes
app.get('/', (req: Request, res: Response) => {
  res.send('Entrepreneur Journey API is running');
});

// MARK: - Business Ideas API

// Get all ideas
app.get('/v1/ideas', async (req: Request, res: Response) => {
  try {
    const ideas = await prisma.businessIdea.findMany({
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    console.log('Fetching all ideas, count:', ideas.length);
    res.json(ideas);
  } catch (error) {
    console.error('Error fetching ideas:', error);
    res.status(500).json({ error: 'Failed to fetch business ideas' });
  }
});

// Get a specific idea
app.get('/v1/ideas/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Fetching idea with ID: ${req.params.id}`);
    const idea = await prisma.businessIdea.findUnique({
      where: {
        id: req.params.id as string
      }
    });
    
    if (!idea) {
      return res.status(404).json({ error: 'Business idea not found' });
    }
    
    res.json(idea);
  } catch (error) {
    console.error('Error fetching idea:', error);
    res.status(500).json({ error: 'Failed to fetch business idea' });
  }
});

// Create a new idea
app.post('/v1/ideas', async (req: Request, res: Response) => {
  try {
    const { description, targetMarket, effort, reward, date } = req.body;
    console.log('Received idea:', JSON.stringify(req.body));
    
    const newIdea = await prisma.businessIdea.create({
      data: {
        description: description || '',
        targetMarket: targetMarket || '',
        effort: effort || '',
        reward: reward || '',
        date: date || new Date().toISOString()
      }
    });
    
    console.log('Created idea:', JSON.stringify(newIdea));
    res.status(201).json(newIdea);
  } catch (error) {
    console.error('Error creating idea:', error);
    res.status(500).json({ error: 'Failed to create business idea' });
  }
});

// Update an idea
app.put('/v1/ideas/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Updating idea with ID: ${req.params.id}`);
    console.log('Update data:', JSON.stringify(req.body));
    
    const { description, targetMarket, effort, reward, date } = req.body;
    
    const updatedIdea = await prisma.businessIdea.update({
      where: {
        id: req.params.id as string
      },
      data: {
        description: description,
        targetMarket: targetMarket,
        effort: effort,
        reward: reward,
        date: date
      }
    });
    
    console.log('Updated idea:', JSON.stringify(updatedIdea));
    res.json(updatedIdea);
  } catch (error: any) {
    console.error('Error updating idea:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Business idea not found' });
    }
    res.status(500).json({ error: 'Failed to update business idea' });
  }
});

// Delete an idea
app.delete('/v1/ideas/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Deleting idea with ID: ${req.params.id}`);
    
    await prisma.businessIdea.delete({
      where: {
        id: req.params.id as string
      }
    });
    
    console.log('Idea deleted successfully');
    res.json({ message: 'Business idea deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting idea:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Business idea not found' });
    }
    res.status(500).json({ error: 'Failed to delete business idea' });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
