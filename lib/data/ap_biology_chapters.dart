import 'ap_course_chapters.dart';

/// AP Biology chapters (condensed units with sample questions).
final List<APCourseChapter> apBiologyChapters = [
  APCourseChapter(
    name: 'Chemistry of Life',
    description: 'Water, macromolecules, and enzymes',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Proteins are made of:',
        options: ['Amino acids', 'Nucleotides', 'Sugars', 'Fatty acids'],
        correctIndex: 0,
        explanation: 'Proteins are polymers of amino acids.',
      ),
      ChapterQuestion(
        questionText: 'Enzymes function as:',
        options: ['Catalysts', 'Reactants', 'Products', 'Inhibitors only'],
        correctIndex: 0,
        explanation: 'Enzymes speed up reactions without being consumed.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Cell Structure',
    description: 'Cell components and membranes',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'The cell membrane is composed of:',
        options: ['Phospholipid bilayer', 'Cellulose', 'Peptidoglycan', 'Chitin'],
        correctIndex: 0,
        explanation: 'Cell membranes are phospholipid bilayers.',
      ),
      ChapterQuestion(
        questionText: 'Mitochondria are the site of:',
        options: ['Cellular respiration', 'Photosynthesis', 'Protein synthesis', 'DNA replication'],
        correctIndex: 0,
        explanation: 'Mitochondria produce ATP via cellular respiration.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Cellular Energetics',
    description: 'Photosynthesis and respiration',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Photosynthesis occurs in:',
        options: ['Chloroplasts', 'Mitochondria', 'Nucleus', 'Ribosomes'],
        correctIndex: 0,
        explanation: 'Chloroplasts are the site of photosynthesis.',
      ),
      ChapterQuestion(
        questionText: 'ATP is produced during:',
        options: ['Cellular respiration', 'DNA replication', 'Transcription', 'Translation'],
        correctIndex: 0,
        explanation: 'Cellular respiration generates ATP.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Genetics',
    description: 'Inheritance, DNA, and gene expression',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'DNA is transcribed into:',
        options: ['RNA', 'Protein', 'Lipids', 'Carbohydrates'],
        correctIndex: 0,
        explanation: 'Transcription produces RNA from DNA.',
      ),
      ChapterQuestion(
        questionText: 'A phenotype is:',
        options: ['Observable traits', 'Genetic code only', 'Mutation only', 'Chromosome number'],
        correctIndex: 0,
        explanation: 'Phenotype refers to observable characteristics.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Evolution',
    description: 'Natural selection and population genetics',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Natural selection favors:',
        options: ['Traits that improve fitness', 'Random traits only', 'All traits equally', 'Harmful traits'],
        correctIndex: 0,
        explanation: 'Traits that improve survival and reproduction are favored.',
      ),
      ChapterQuestion(
        questionText: 'Speciation occurs when:',
        options: ['Populations become reproductively isolated', 'Populations merge', 'All species are identical', 'Genes stop mutating'],
        correctIndex: 0,
        explanation: 'Reproductive isolation leads to speciation.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Ecology',
    description: 'Ecosystems, interactions, and biodiversity',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Primary producers are:',
        options: ['Autotrophs', 'Herbivores', 'Carnivores', 'Decomposers'],
        correctIndex: 0,
        explanation: 'Autotrophs produce energy-rich compounds.',
      ),
      ChapterQuestion(
        questionText: 'Carrying capacity refers to:',
        options: ['Maximum sustainable population', 'Minimum population', 'Birth rate', 'Death rate'],
        correctIndex: 0,
        explanation: 'Carrying capacity is the max population an environment supports.',
      ),
    ],
  ),
];
