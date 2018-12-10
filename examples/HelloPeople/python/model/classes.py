from dataclay import DataClayObject, dclayMethod


class Person(DataClayObject):
    """
    @ClassField name str
    @ClassField age int
    """
    @dclayMethod(name='str', age='int')
    def __init__(self, name, age):
        self.name = name
        self.age = age


class People(DataClayObject):
    """
    @ClassField people list<HelloPeople_ns.classes.Person>
    """
    @dclayMethod()
    def __init__(self):
        self.people = list()

    @dclayMethod(new_person="HelloPeople_ns.classes.Person")
    def add(self, new_person):
        self.people.append(new_person)

    @dclayMethod(return_="str")
    def __str__(self):
        result = ["People:"]

        for p in self.people:
            result.append(" - Name: %s, age: %d" % (p.name, p.age))

        return "\n".join(result)
