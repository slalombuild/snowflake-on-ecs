import docker
import os
import re


def test_run_dag_tests():
    """
    This function runs a docker exec command on the container and will run our
    airflow DAG testing script. Once the test is complete return the exit
    status and output messsage from the docker execute command. Then the
    function stops the container.
    :return: the exit status and output message from the docker exec command
        of test script.
    """

    dn = os.path.dirname(__file__)

    dags = re.sub("test$", "airflow/dags", dn)
    test = re.sub("test$", "airflow/test", dn)

    running_container = airflow_build(
        dag_path=dags, test_path=test
    )

    dag_test_output = running_container.exec_run(
        "pytest /airflow/test/test_dags.py"
    )
    ex_code = dag_test_output[0]

    running_container.stop()

    assert ex_code == 0


def airflow_build(dag_path, test_path):
    """
    This function runs the build for a container with airflow processes
    locally. Turns on webserver and scheduler.
    :param dag_path: (string) the filepath where dags live locally.
    :param test_path: (string) the filepath where the pytest script lives
        locally.
    :return: returns the docker container object.
    """

    image_name = "slalombuild/airflow-ecs"

    client = docker.from_env()
    #  client.images.pull(image_name)
    running_container = client.containers.run(
        image_name,
        detach=True,
        remove=True,
        volumes={
            dag_path: {"bind": "/airflow/dags/", "mode": "rw"},
            test_path: {"bind": "/airflow/test/", "mode": "rw"},
        },
    )
    return running_container
