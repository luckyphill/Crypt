find_package(Chaste COMPONENTS continuum_mechanics global io linalg mesh ode pde cell_based crypt)

# Alternatively, to specify a Chaste installation directory use a line like that below.
# This is needed if your project is not contained in the projects folder within a Chaste source tree.
#find_package(Chaste COMPONENTS heart crypt PATHS /path/to/chaste-install NO_DEFAULT_PATH)

chaste_do_project(LabellingIndex)
