// Copyright 2009-2015 Sandia Corporation. Under the terms
// of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S.
// Government retains certain rights in this software.
// 
// Copyright (c) 2009-2015, Sandia Corporation
// All rights reserved.
// 
// This file is part of the SST software package. For license
// information, see the LICENSE file in the top level directory of the
// distribution.

#include <stdio.h>

int main(int argc, char* argv[]) {

	float the_sum = 0;
	int i = 0;

	for( i = 0 ; i < 1024; i++) {
		the_sum += (float) i * 1.51;
	}

	printf("#SSTTEST Sum is %f\n", the_sum);

	return 0;
}
