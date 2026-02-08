import 'ap_course_chapters.dart';

/// AP Environmental Science chapters (condensed units with sample questions).
final List<APCourseChapter> apEnvironmentalScienceChapters = [
  APCourseChapter(
    name: 'Earth Systems',
    description: 'Climate, atmosphere, and geosphere',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'The greenhouse effect is caused by:',
        options: ['Greenhouse gases trapping heat', 'Ozone depletion', 'Ocean tides', 'Earth’s rotation'],
        correctIndex: 0,
        explanation: 'Greenhouse gases trap outgoing infrared radiation.',
      ),
      ChapterQuestion(
        questionText: 'A carbon sink is:',
        options: ['A reservoir that stores carbon', 'A source of carbon only', 'A pollutant', 'A fossil fuel'],
        correctIndex: 0,
        explanation: 'Carbon sinks store carbon long-term.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Ecology',
    description: 'Ecosystems, energy flow, and cycles',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Producers are:',
        options: ['Autotrophs', 'Herbivores', 'Carnivores', 'Decomposers'],
        correctIndex: 0,
        explanation: 'Producers make their own food via photosynthesis.',
      ),
      ChapterQuestion(
        questionText: 'Most energy is lost between trophic levels as:',
        options: ['Heat', 'Biomass', 'Water', 'Oxygen'],
        correctIndex: 0,
        explanation: 'Energy is lost as heat during metabolism.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Biodiversity',
    description: 'Species diversity and conservation',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Biodiversity supports:',
        options: ['Ecosystem stability', 'Pollution', 'Extinction', 'Uniform habitats'],
        correctIndex: 0,
        explanation: 'Higher biodiversity increases stability and resilience.',
      ),
      ChapterQuestion(
        questionText: 'An invasive species often:',
        options: ['Outcompetes native species', 'Improves biodiversity', 'Has no impact', 'Reduces resources use'],
        correctIndex: 0,
        explanation: 'Invasive species can outcompete and reduce native populations.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Population',
    description: 'Population growth and dynamics',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Exponential growth occurs when:',
        options: ['Resources are unlimited', 'Resources are limited', 'Population is stable', 'Birth rate is zero'],
        correctIndex: 0,
        explanation: 'Exponential growth assumes unlimited resources.',
      ),
      ChapterQuestion(
        questionText: 'Carrying capacity is:',
        options: ['Maximum sustainable population', 'Minimum population', 'Birth rate', 'Death rate'],
        correctIndex: 0,
        explanation: 'Carrying capacity is the maximum population an environment can sustain.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Energy Resources',
    description: 'Renewable and nonrenewable resources',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'A renewable energy source is:',
        options: ['Solar', 'Coal', 'Oil', 'Natural gas'],
        correctIndex: 0,
        explanation: 'Solar is renewable; fossil fuels are not.',
      ),
      ChapterQuestion(
        questionText: 'Fossil fuels are considered:',
        options: ['Nonrenewable', 'Renewable', 'Unlimited', 'Carbon neutral'],
        correctIndex: 0,
        explanation: 'Fossil fuels take millions of years to form.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Pollution & Climate',
    description: 'Air, water, and climate impacts',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Acid rain is mainly caused by:',
        options: ['SO2 and NOx', 'CO2 only', 'Ozone', 'Methane'],
        correctIndex: 0,
        explanation: 'SO2 and NOx form acids in the atmosphere.',
      ),
      ChapterQuestion(
        questionText: 'Climate change is primarily linked to:',
        options: ['Greenhouse gas emissions', 'Volcanoes only', 'Solar flares', 'Ocean tides'],
        correctIndex: 0,
        explanation: 'Greenhouse gas emissions drive modern climate change.',
      ),
    ],
  ),
];
