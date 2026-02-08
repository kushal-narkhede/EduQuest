import 'ap_course_chapters.dart';

/// AP Chemistry chapters (condensed units with sample questions).
final List<APCourseChapter> apChemistryChapters = [
  APCourseChapter(
    name: 'Atomic Structure',
    description: 'Atoms, isotopes, and electron configuration',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Atomic number represents:',
        options: ['Protons', 'Neutrons', 'Electrons + neutrons', 'Mass'],
        correctIndex: 0,
        explanation: 'Atomic number equals the number of protons.',
      ),
      ChapterQuestion(
        questionText: 'Isotopes differ in number of:',
        options: ['Protons', 'Neutrons', 'Electrons', 'Atomic number'],
        correctIndex: 1,
        explanation: 'Isotopes have the same protons but different neutrons.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Bonding and Structure',
    description: 'Ionic, covalent, and molecular geometry',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Ionic bonds form between:',
        options: ['Metals and nonmetals', 'Nonmetals only', 'Metals only', 'Noble gases'],
        correctIndex: 0,
        explanation: 'Ionic bonds are typically metal + nonmetal.',
      ),
      ChapterQuestion(
        questionText: 'VSEPR theory predicts:',
        options: ['Molecular shape', 'Reaction rate', 'pH', 'Solubility'],
        correctIndex: 0,
        explanation: 'VSEPR models electron pair repulsion to predict geometry.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Gases',
    description: 'Gas laws and kinetic molecular theory',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Ideal gas law is:',
        options: ['PV = nRT', 'P = nRT', 'PV = RT', 'P = V/nRT'],
        correctIndex: 0,
        explanation: 'PV = nRT relates pressure, volume, and temperature.',
      ),
      ChapterQuestion(
        questionText: 'At constant T, increasing V causes P to:',
        options: ['Decrease', 'Increase', 'Stay the same', 'Become zero'],
        correctIndex: 0,
        explanation: 'Boyle’s law: P is inversely proportional to V.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Thermochemistry',
    description: 'Energy changes and enthalpy',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Exothermic reactions have ΔH:',
        options: ['Negative', 'Positive', 'Zero', 'Undefined'],
        correctIndex: 0,
        explanation: 'Exothermic processes release heat (negative ΔH).',
      ),
      ChapterQuestion(
        questionText: 'Calorimetry measures:',
        options: ['Heat transfer', 'Pressure', 'Volume', 'Moles'],
        correctIndex: 0,
        explanation: 'Calorimeters measure heat absorbed or released.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Kinetics and Equilibrium',
    description: 'Reaction rates and equilibrium',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'A catalyst does what?',
        options: ['Lowers activation energy', 'Raises activation energy', 'Changes ΔH', 'Stops reaction'],
        correctIndex: 0,
        explanation: 'Catalysts lower activation energy and speed reactions.',
      ),
      ChapterQuestion(
        questionText: 'At equilibrium, the reaction rates are:',
        options: ['Equal', 'Zero', 'Infinite', 'Always decreasing'],
        correctIndex: 0,
        explanation: 'Forward and reverse rates are equal at equilibrium.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Acids, Bases, and Electrochemistry',
    description: 'pH, buffers, and redox',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'pH is defined as:',
        options: ['-log[H+]', 'log[H+]', '-log[OH-]', 'log[OH-]'],
        correctIndex: 0,
        explanation: 'pH = -log[H+].',
      ),
      ChapterQuestion(
        questionText: 'Oxidation is:',
        options: ['Loss of electrons', 'Gain of electrons', 'Gain of protons', 'Loss of protons'],
        correctIndex: 0,
        explanation: 'Oxidation is loss of electrons (OIL).',
      ),
    ],
  ),
];
