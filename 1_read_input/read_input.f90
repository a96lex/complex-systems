program ex1
    ! Convert input into structured graph data
    ! This program assumes input nodes' nomenclature is consecutive integers starting at 1
    implicit none
    integer, allocatable :: neighbours(:), pointer_i(:), pointer_f(:), cardinality(:)
    integer :: N = 0, E = 0
    integer :: node1, node2 ! for reading input file
    integer :: iostat, i ! helper integers
    character (len=100) :: filename

    print*, "Write the name of the input file"
    read (*, *) filename

    open (unit = 1, file = filename, status = "old", action = "read")

    ! 1st input read: find N and E
    do
        read(unit = 1, fmt = *, iostat = iostat) node1, node2
        if (iostat .ne. 0) exit

        if (node1 > N) N = node1
        if (node2 > N) N = node2
        E = E +1

    enddo

    ! Allocate vectors
    allocate(neighbours(2*E), pointer_i(N), pointer_f(N), cardinality(N))

    ! 2nd input read: find cardinality of all nodes
    cardinality = 0
    rewind(unit = 1)

    do
        read(unit = 1, fmt = *, iostat = iostat)  node1, node2
        if (iostat .ne. 0) exit 
        cardinality(node1) = cardinality(node1)+1
        cardinality(node2) = cardinality(node2)+1
    enddo   
    
    ! Construct pointer vectors
    pointer_i(1) = 1
    pointer_f(1) = cardinality(1)

    do i = 2, N
        pointer_i(i) = pointer_f(i-1) + 1
        pointer_f(i) = pointer_f(i-1) + cardinality(i) 
    enddo

    ! 3rd input read: construct main vector
    neighbours = 0
    pointer_f = pointer_i - 1
    rewind(unit = 1)

    do
        read(unit = 1, fmt = *, iostat = iostat)  node1, node2
        if (iostat .ne. 0) exit
        pointer_f(node1) = pointer_f(node1) + 1
        pointer_f(node2) = pointer_f(node2) + 1
        neighbours(pointer_f(node1)) = node2 
        neighbours(pointer_f(node2)) = node1 
    enddo

end program ex1