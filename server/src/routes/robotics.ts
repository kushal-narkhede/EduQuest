import { Router } from 'express';
import { CourseModel, ModuleModel, AssessmentModel } from '../models/roboticsModels';

const router = Router();

// GET /courses/robotics
router.get('/courses/robotics', async (req, res) => {
  try {
    const course = await CourseModel.findOne({ title: 'Robotics' });
    if (!course) return res.status(404).json({ error: 'Course not found' });
    return res.json(course);
  } catch (e) {
    return res.status(500).json({ error: 'Server error', details: String(e) });
  }
});

// GET /modules/:courseId with pagination and filtering
router.get('/modules/:courseId', async (req, res) => {
  try {
    const { courseId } = req.params;
    const { difficulty, tags: tagsParam, modes: modesParam, page = '1', pageSize = '20' } = req.query as any;
    const pageNum = Math.max(1, parseInt(page));
    const pageSizeNum = Math.min(100, Math.max(1, parseInt(pageSize)));
    const skip = (pageNum - 1) * pageSizeNum;

    const filter: any = { courseId };
    if (difficulty) filter.difficulty = difficulty;
    if (tagsParam) {
      const tagArray = Array.isArray(tagsParam) ? tagsParam : tagsParam.split(',');
      filter.tags = { $in: tagArray };
    }
    if (modesParam) {
      const modeArray = Array.isArray(modesParam) ? modesParam : modesParam.split(',');
      filter.modes = { $in: modeArray };
    }

    const modules = await ModuleModel.find(filter).skip(skip).limit(pageSizeNum);
    const total = await ModuleModel.countDocuments(filter);
    return res.json({ items: modules, total, page: pageNum, pageSize: pageSizeNum });
  } catch (e) {
    return res.status(500).json({ error: 'Server error', details: String(e) });
  }
});

// GET /assessments/:moduleId with filtering and pagination
router.get('/assessments/:moduleId', async (req, res) => {
  try {
    const { moduleId } = req.params;
    const { type, difficulty, tags: tagsParam, modes: modesParam, page = '1', pageSize = '50' } = req.query as any;
    const pageNum = Math.max(1, parseInt(page));
    const pageSizeNum = Math.min(100, Math.max(1, parseInt(pageSize)));
    const skip = (pageNum - 1) * pageSizeNum;

    const filter: any = { moduleId };
    if (type) filter.type = type;
    if (difficulty) filter.difficulty = difficulty;
    if (tagsParam) {
      const tagArray = Array.isArray(tagsParam) ? tagsParam : tagsParam.split(',');
      filter.tags = { $in: tagArray };
    }
    if (modesParam) {
      const modeArray = Array.isArray(modesParam) ? modesParam : modesParam.split(',');
      filter.modes = { $in: modeArray };
    }

    const items = await AssessmentModel.find(filter).skip(skip).limit(pageSizeNum);
    const total = await AssessmentModel.countDocuments(filter);
    return res.json({ items, total, page: pageNum, pageSize: pageSizeNum });
  } catch (e) {
    return res.status(500).json({ error: 'Server error', details: String(e) });
  }
});

// POST /sync/robotics
// Upserts course/modules/assessments based on version + last_updated
router.post('/sync/robotics', async (req, res) => {
  try {
    const payload = req.body || {};
    const { course, modules = [], assessments = [] } = payload;

    // Upsert course
    let courseDoc = await CourseModel.findOne({ title: 'Robotics' });
    if (!courseDoc) {
      courseDoc = await CourseModel.create(course);
    } else {
      if ((course.metadata?.version ?? 1) >= courseDoc.metadata.version) {
        courseDoc.set(course);
        courseDoc.metadata.last_updated = new Date();
        await courseDoc.save();
      }
    }

    // Upsert modules
    for (const m of modules) {
      const existing = await ModuleModel.findOne({ courseId: courseDoc._id, title: m.title });
      if (!existing) {
        await ModuleModel.create({ ...m, courseId: courseDoc._id });
      } else if ((m.metadata?.version ?? 1) >= existing.metadata.version) {
        existing.set({ ...m, courseId: courseDoc._id });
        existing.metadata.last_updated = new Date();
        await existing.save();
      }
    }

    // Upsert assessments
    for (const a of assessments) {
      const existing = await AssessmentModel.findOne({ moduleId: a.moduleId, prompt: a.prompt });
      if (!existing) {
        await AssessmentModel.create(a);
      } else if ((a.metadata?.version ?? 1) >= existing.metadata.version) {
        existing.set(a);
        existing.metadata.last_updated = new Date();
        await existing.save();
      }
    }

    return res.json({ ok: true });
  } catch (e) {
    return res.status(500).json({ error: 'Server error', details: String(e) });
  }
});

export default router;
