from airflow.models import DagBag
import re


def test_import_dags():
    """
    Pytest to ensure there will be no import errors in dagbag. These are
    generally syntax problems.
    """
    dags = DagBag()

    assert len(dags.import_errors) == 0


def test_alert_email_present():
    """
    Pytest to ensure all dags have a valid email address
    """

    dags = DagBag()
    email_regex = re.compile(
        r"^[A-Za-z0-9\.\+_-]+@[A-Za-z0-9\._-]+\.[a-zA-Z]*$"
    )  # regex to check for valid email

    for dag_id, dag in dags.dags.items():
        emails = dag.default_args.get("email", [])
        for email in emails:
            assert email_regex.match(email) is not None
