package model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import dataclay.DataClayObject;

/**
 * This class represents a City.
 */
public class City extends DataClayObject {

	/** Events in this City area. */
	private List<Event> events;

	/** Aggregation of events in this City. */
	private AggregatedEvents aggregation;

	/**
	 * Constructor.
	 */
	public City() {
		this.setEvents(new ArrayList<>());
		this.setAggregation(new AggregatedEvents());
	}

	/**
	 * Gets aggregation.
	 * 
	 * @return the aggregation
	 */
	public AggregatedEvents getAggregation() {
		return aggregation;
	}

	/**
	 * Sets aggregation
	 * 
	 * @param theaggregation
	 *            the aggregation to set
	 */
	public void setAggregation(final AggregatedEvents aggregation) {
		this.aggregation = aggregation;
	}

	/**
	 * Gets events.
	 * 
	 * @return the events
	 */
	public List<Event> getEvents() {
		return events;
	}

	/**
	 * Sets events
	 * 
	 * @param theevents
	 *            the events to set
	 */
	public void setEvents(final List<Event> events) {
		this.events = events;
	}

	/**
	 * Add all events provided to the list of events of this city.
	 * 
	 * @param events
	 *            Events to add
	 */
	public void addAllEvents(final Collection<Event> events) {
		this.events.addAll(events);
		this.aggregation.incrementEvents(events.size());
	}

}
