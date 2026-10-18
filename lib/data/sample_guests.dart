import '../models/guest.dart';

/// Fictional guests that seed an empty database, so a fresh install (and the
/// public web demo) shows how the app works. Every name here is made up.
///
/// Real guest lists are not part of the repository: import them as CSV from
/// the guest list screen.
final sampleGuests = <Guest>[
  for (final (i, g) in _seed.indexed)
    Guest(
      id: i + 1,
      name: g.$1,
      place: g.$2,
      relation: g.$3,
      number: g.$4,
      category: g.$5,
      status: g.$6,
    ),
];

// (name, place, relation, number of people, category, invitation done)
const _seed = [
  ('Arjun Mehra', 'Gaon', 'N/A', 4, 'Cards Distribution', true),
  ('Kavita Rathore', 'Gaon', 'N/A', 3, 'Cards Distribution', false),
  ('Rohit Saini', 'Gaon', 'N/A', 5, 'Cards Distribution', true),
  ('Meena Kumari', 'Gaon', 'N/A', 2, 'Cards Distribution', false),
  ('Suresh Yadav', 'Colony', 'N/A', 4, 'Cards Distribution', true),
  ('Anjali Joshi', 'Colony', 'N/A', 3, 'Cards Distribution', false),
  ('Vikram Chauhan', 'Colony', 'N/A', 2, 'Cards Distribution', false),
  ('Pooja Bansal', 'Colony', 'N/A', 4, 'Cards Distribution', true),
  ('Deepak Verma', 'Staff', 'N/A', 1, 'Cards Distribution', true),
  ('Neha Kapoor', 'Staff', 'N/A', 2, 'Cards Distribution', false),
  ('Ramesh Gupta', 'Staff', 'N/A', 1, 'Cards Distribution', false),
  ('Sunita Devi', 'Nanihal', 'N/A', 3, 'Cards Distribution', true),
  ('Mahesh Prajapat', 'Gaon', 'Jija Ji', 4, 'Besh', true),
  ('Lalita Sharma', 'Gaon', 'Nanad', 3, 'Besh', false),
  ('Harish Meena', 'Nanihal', 'Fufa Ji', 2, 'Besh', false),
  ('Geeta Saini', 'Nanihal', 'Bhua Ji', 2, 'Besh', true),
  ('Manoj Choudhary', 'Gaon', 'N/A', 5, 'Besh', false),
  ('Rekha Jangid', 'Colony', 'Jethani', 2, 'Besh', true),
  ('Prakash Soni', 'Gaon', 'Jija Ji', 3, 'Juhari', true),
  ('Kamla Devi', 'Gaon', 'Devarani', 2, 'Juhari', false),
  ('Naresh Kumawat', 'Gaon', 'N/A', 4, 'Juhari', false),
  ('Asha Rani', 'Nanihal', 'Bhanji', 1, 'Juhari', true),
  ('Gopal Swami', 'Gaon', 'N/A', 3, 'Bhati - Juhari I', true),
  ('Ritika Kanwar', 'Gaon', 'Jethuti', 2, 'Bhati - Juhari I', false),
  ('Dinesh Pareek', 'Colony', 'N/A', 4, 'Bhati - Juhari II', false),
  ('Usha Agarwal', 'Colony', 'Nanad', 2, 'Bhati - Juhari II', true),
  ('Mukesh Tanwar', 'Gaon', 'N/A', 3, 'Bhati - Juhari III', false),
  ('Saroj Bai', 'Nanihal', 'Bhua Ji', 2, 'Bhati - Juhari III', true),
];
