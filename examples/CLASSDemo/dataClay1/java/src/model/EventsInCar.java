package model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dataclay.DataClayObject;

/**
 * This class contains all Events of a Car.
 */
public class EventsInCar extends DataClayObject {

	/** Events of this car at certain position. */
	private Map<Position, Event> events;

	/**
	 * Constructor.
	 */
	public EventsInCar() {
		this.setEvents(new HashMap<>());
	}

	/**
	 * Gets events.
	 * 
	 * @return the events
	 */
	public Map<Position, Event> getEvents() {
		return events;
	}

	/**
	 * Sets events
	 * 
	 * @param theevents
	 *            the events to set
	 */
	public void setEvents(final Map<Position, Event> events) {
		this.events = events;
	}

	/**
	 * Add event to this Car.
	 * 
	 * @param event
	 */
	public void addEvent(final Event event) {
		this.events.put(event.getPosition(), event);
	}

	@Override
	public void whenFederated() {
		// This is executed in a city fog node. Since they are independent dataClays,
		// the alias can be fixed.
		final City city = (City) City.getByAlias("my-city");
		final List<Event> currentEvents = new ArrayList<>(this.events.values());
		city.addAllEvents(currentEvents);
	}

	@Override
	public String toString() {
		String result = "[\n";
		for (final Event event : events.values()) {
			result += event.toString() + "\n";
		}
		result += "]";
		return result;
	}
}
