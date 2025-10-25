import express = require('express');
import cors = require('cors');
import bodyParser = require('body-parser');
import { PrismaClient, Prisma } from '@prisma/client';
import dotenv from 'dotenv';
type Request = express.Request;
type Response = express.Response;

// Initialize Prisma Client
const prisma = new PrismaClient();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
dotenv.config();

// API Token Authentication Middleware
const authMiddleware = (req: Request, res: Response, next: Function) => {
  const token = req.headers['x-api-token'] as string;
  const expectedToken = process.env.API_TOKEN;
  
  if (!token || token !== expectedToken) {
    return res.status(401).json({ error: 'Unauthorized: Invalid or missing API token' });
  }
  
  next();
};

// Apply auth middleware to all /v1 routes
app.use('/v1', authMiddleware);

// Define the BusinessIdea interface (matching Prisma model)
interface BusinessIdea {
  id: number;
  description: string;
  targetMarket: string;
  effort: string;
  reward: string;
  date: string;
  createdAt: Date;
  updatedAt: Date;
}

// Define the User interface (matching Prisma model)
interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
  startedAt?: Date;
}

// Define the DiaryEntry interface (matching Prisma model)
interface DiaryEntry {
  id: number;
  content: string;
  category: 'WANNAPRENEUR' | 'ENTREPRENEUR';
  createdAt: Date;
  updatedAt: Date;
  userId: string;
  ideaId?: string;
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
        id: parseInt(req.params.id as string)
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
    const { description, targetMarket, effort, reward, date, userId } = req.body;
    console.log('Received idea:', JSON.stringify(req.body));
    
    const newIdea = await prisma.businessIdea.create({
      data: {
        description: description || '',
        targetMarket: targetMarket || '',
        effort: effort || '',
        reward: reward || '',
        date: date || new Date().toISOString(),
        userId: userId
      } as Prisma.BusinessIdeaUncheckedCreateInput
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
        id: parseInt(req.params.id as string)
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
        id: parseInt(req.params.id as string)
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

// MARK: - Users API

// Get all users
app.get('/v1/users', async (req: Request, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    console.log('Fetching all users, count:', users.length);
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Get a specific user
app.get('/v1/users/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Fetching user with ID: ${req.params.id}`);
    const user = await prisma.user.findUnique({
      where: {
        id: parseInt(req.params.id as string)
      }
    });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// Create a new user
app.post('/v1/users', async (req: Request, res: Response) => {
  try {
    const { name, email, startedAt } = req.body;
    console.log('Received user:', JSON.stringify(req.body));
    
    const newUser = await prisma.user.create({
      data: {
        name: name || '',
        email: email || '',
        startedAt: startedAt ? new Date(startedAt) : null
      }
    });
    
    console.log('Created user:', JSON.stringify(newUser));
    res.status(201).json(newUser);
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Update a user
app.put('/v1/users/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Updating user with ID: ${req.params.id}`);
    console.log('Update data:', JSON.stringify(req.body));
    
    const { name, email, startedAt } = req.body;
    
    const updatedUser = await prisma.user.update({
      where: {
        id: parseInt(req.params.id as string)
      },
      data: {
        name: name,
        email: email,
        startedAt: startedAt ? new Date(startedAt) : null
      }
    });
    
    console.log('Updated user:', JSON.stringify(updatedUser));
    res.json(updatedUser);
  } catch (error: any) {
    console.error('Error updating user:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// Delete a user
app.delete('/v1/users/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Deleting user with ID: ${req.params.id}`);
    
    await prisma.user.delete({
      where: {
        id: parseInt(req.params.id as string)
      }
    });
    
    console.log('User deleted successfully');
    res.json({ message: 'User deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting user:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

// MARK: - Diary Entries API

// Get all diary entries
app.get('/v1/diary-entries', async (req: Request, res: Response) => {
  try {
    const entries = await prisma.diaryEntry.findMany({
      orderBy: {
        createdAt: 'desc'
      }
    });
    
    console.log('Fetching all diary entries, count:', entries.length);
    res.json(entries);
  } catch (error) {
    console.error('Error fetching diary entries:', error);
    res.status(500).json({ error: 'Failed to fetch diary entries' });
  }
});

// Get a specific diary entry
app.get('/v1/diary-entries/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Fetching diary entry with ID: ${req.params.id}`);
    const entry = await prisma.diaryEntry.findUnique({
      where: {
        id: parseInt(req.params.id as string)
      }
    });
    
    if (!entry) {
      return res.status(404).json({ error: 'Diary entry not found' });
    }
    
    res.json(entry);
  } catch (error) {
    console.error('Error fetching diary entry:', error);
    res.status(500).json({ error: 'Failed to fetch diary entry' });
  }
});

// Create a new diary entry
app.post('/v1/diary-entries', async (req: Request, res: Response) => {
  try {
    const { content, category, userId } = req.body;
    console.log('Received diary entry:', JSON.stringify(req.body));
    
    const newEntry = await prisma.diaryEntry.create({
      data: {
        content: content || '',
        category: category,
        userId: userId,
      }
    });
    
    console.log('Created diary entry:', JSON.stringify(newEntry));
    res.status(201).json(newEntry);
  } catch (error) {
    console.error('Error creating diary entry:', error);
    res.status(500).json({ error: 'Failed to create diary entry' });
  }
});

// Update a diary entry
app.put('/v1/diary-entries/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Updating diary entry with ID: ${req.params.id}`);
    console.log('Update data:', JSON.stringify(req.body));
    
    const { content, category, userId, ideaId } = req.body;
    
    const updatedEntry = await prisma.diaryEntry.update({
      where: {
        id: parseInt(req.params.id as string)
      },
      data: {
        content: content,
        category: category,
        userId: userId,
        ideaId: ideaId
      }
    });
    
    console.log('Updated diary entry:', JSON.stringify(updatedEntry));
    res.json(updatedEntry);
  } catch (error: any) {
    console.error('Error updating diary entry:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Diary entry not found' });
    }
    res.status(500).json({ error: 'Failed to update diary entry' });
  }
});

// Delete a diary entry
app.delete('/v1/diary-entries/:id', async (req: Request, res: Response) => {
  try {
    console.log(`Deleting diary entry with ID: ${req.params.id}`);
    
    await prisma.diaryEntry.delete({
      where: {
        id: parseInt(req.params.id as string)
      }
    });
    
    console.log('Diary entry deleted successfully');
    res.json({ message: 'Diary entry deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting diary entry:', error);
    if (error.code === 'P2025') {
      return res.status(404).json({ error: 'Diary entry not found' });
    }
    res.status(500).json({ error: 'Failed to delete diary entry' });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
