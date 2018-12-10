package app;

import dataclay.api.DataClay;
import model.People;
import model.Person;

public class HelloPeople {
	private static void usage() {
		System.out.println("Usage: application.HelloPeople <peopleAlias> <personName> <personAge>");
		System.exit(1);
	}

	public static void main(final String[] args) {
		try {
			// Check and parse arguments
			if (args.length != 3) {
				usage();
			}
			final String peopleAlias = args[0];
			final String pName = args[1];
			final int pAge = Integer.parseInt(args[2]);

			// Init dataClay session
			DataClay.init();

			// Access (or create collection)
			People people = null;
			try {
				people = People.getByAlias(peopleAlias);
				System.out.println("[LOG] People object " + peopleAlias + " found.");
			} catch (final Exception ex) {
				System.out.println("[LOG] Creating NEW object People");
				people = new People();
				people.makePersistent(peopleAlias);
			}

			// Create person
			final Person person = new Person(pName, pAge);
			person.makePersistent();
			people.add(person);

			// Print people (people iterated remotely)
			System.out.println(people);

			// Finish dataClay session
			DataClay.finish();

			// Exit
			System.exit(0);
		} catch (final Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
